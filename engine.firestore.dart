import 'package:clientf/settings.dart';

import './engine.defines.dart';
import 'package:flutter/material.dart';

// import 'package:clientf/services/app.service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';



/// 사진(파일)을 `Firestore`에 올리고, 삭제 등 전반 적인 관리를 한다.
///
/// 이 모듈은 `Engine`과 직접적인 연관이 없다.
///
/// * 사진을 업로드하고 삭제하는 루틴은 `Engine`과 완전히 분리되어져 있다.
///
/// * 이 모듈은 주로 사진을 카메라로 찍거나 갤러리에서 가져와서 Firestore 에 업로드하고 URL 업로드된 이미지의 URL 을 리턴한다.
///   이 과정에서 `Engine`과 직접적인 연동은 없다.
///
/// * `Firestore`에 업로드한 사진의 URL 들을 입력 변수 [doc.urls] 배열로 보관하고 `Firestore`에서 삭제를 하면 [doc.urls]를 업데이트한다.
///
/// * 업로드를 할 때, 업로드 Progressbar 를 표시하고, 사진을 보여주는 Helper class 가 연동되어 사용된다.
///
/// 준비 사항
///
/// * image_picker 플러그인을 설치하고 IDE에 설정.
/// * firebase_firestore 플러그인을 설치하고 설정.
/// * Firebase 콘솔에서 해당 프로젝트의 Firestore 생성 및 적절한 권한 설정
///
/// 사진 삭제
///
/// * 파일(사진) 삭제를 할 때, [doc] 에 값을 주고 초기화 하여 `delete` 메소를 호출하면 된다.
///
/// 참고
/// * 사용자 사진(프로필 사진)을 등록하면 `Firebase Auth`의 `photoUrl` 속성에 등록되어져야 한다.
///   그래서 회원 가입, 정보 수정을 할 때, [doc.urls] 의 URL 을 `photoUrl`로 복사해서 백엔드로 전송을 하면 된다.
class EngineFirestore {
  StorageUploadTask uploadTask;
  var doc;
  EngineFirestore(this.doc);

  /// 사진을 선택하고 업로드 한다.
  ///
  /// * 카메라로 부터 사진을 직거나 갤러리로 부터 사진을 가져 올 수 있다.
  /// * permission_handler 플러그인으로 권한 검사를 한다.
  ///
  ///
  /// ``` dart
  ///   var image = await pickImage(
  ///       context,
  ///       index,
  ///       maxWidth: 640,
  ///       imageQuality: 80,
  ///    );
  /// ```
  ///
  ///
  /// [onUploadPercentage] 업로드 상태를 백분율로 표시
  /// [onUploadComplete] 업로드가 끝나면 호출
  /// 에러가 있으면 throw 한다.
  ///
  Future<String> pickAndUploadImage(
    context,
    num sourceIdx, {
    double maxWidth = 1024,
    int imageQuality = 85,
    @required Function onUploadPercentage,
    @required Function onUploadComplete,
  }) async {
    File file;
    const source = [ImageSource.camera, ImageSource.gallery];
    const permissionGroups = [Permission.contacts, Permission.photos];

    /// 권한 검사
    bool haveAccess = await requestPermission(permissionGroups[sourceIdx]);

    /// 권한이 있는가?
    if (haveAccess) {
      file = await ImagePicker.pickImage(
        source: source[sourceIdx],
        maxWidth: maxWidth,
        imageQuality: imageQuality,
      );

      print('got file: $file');
      if (file != null) {
        file = await compressAndGetImage(file);

        /// 성공이면 사진 URL 을 리턴
        return await upload(file, onUploadPercentage, onUploadComplete);
      }
    } else {
      /// 권한이 없으면 알림을 한다.
      /// 참고로 Android 에서는 항상 권한이 허용되어져 있다. 그래서 iOS 에서만 알림을 표시해도 된다.
      throw ERROR_CAMERA_PERMISSION;
    }

    return null;

    // return file;
  }

  /// `check permission` for certain device function access
  ///
  /// TODO: iOS 에서 권한을 두번 물어 보는데, 한번으로 줄일 것.
  ///
  Future<bool> requestPermission(Permission permission) async {
    // You can can also directly ask the permission about its status.
    if (await Permission.location.isRestricted) {
      // The OS restricts access, for example because of parental controls.
      return false;
    }
    if (await Permission.contacts.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      return true;
    } else {
      return false;
    }
  }

  /// compress file and returns it.
  /// also fixing orientation issue when taking images via camera.
  Future<File> compressAndGetImage(File image) async {
    if (image == null) return null;
    var fileAsBytes = await image.readAsBytes();
    await image.delete();
    final compressedImageBytes =
        await FlutterImageCompress.compressWithList(fileAsBytes);
    await image.writeAsBytes(compressedImageBytes);
    return image;
  }

  /// Starts an upload task
  Future<String> upload(
      File file, Function onUploadPercentage, Function onUploadComplete) async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: storageLink);

    /// Unique file name for the file
    String filePath = 'images/${DateTime.now()}.jpg';

    print(filePath);
    print(file);
    uploadTask = _storage.ref().child(filePath).putFile(file);
    double uploadPercentage = 0;

    /// 업로드 Progress Listener
    if (onUploadPercentage != null) {
      uploadTask.events.listen((event) {
        uploadPercentage = 100 *
            (event.snapshot.bytesTransferred.toDouble() /
                event.snapshot.totalByteCount.toDouble());
        // print(uploadPercentage);
        onUploadPercentage(uploadPercentage.round());
      });
    }

    await uploadTask.onComplete;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(filePath);

    var _uploadedUrl = await storageReference.getDownloadURL();

    /// 도큐먼트의 [urls] 속성에 업로드한 사진 URL을 추가한다.
    doc.urls.add(_uploadedUrl);

    /// 업로드 성공
    if (onUploadComplete != null) {
      onUploadComplete(_uploadedUrl);
      onUploadPercentage(0); // Percentage 를 0 으로 해서, Progress Bar 가 사라지게 함.
    }
    return _uploadedUrl;
  }

  Future delete(String url) async {
    // print(doc);
    // print(url);
    var ref = await FirebaseStorage.instance.getReferenceFromUrl(url);

    List urls = doc.urls;
    try {
      await ref.delete();

      urls.removeWhere((element) => element == url);
      print('remove photo: urls:');
      print(urls);
    } catch (e) {
      print('Got error .... remove anyway');

      /// TODO: 파일이 존재하지 않으면 그냥 삭제한다. 다만, 다른 에러가 있을 수 있으니 확인이 필요하다.
      urls.removeWhere((element) => element == url);
      print(e);

      print('remove photo: urls:');
      print(urls);
      throw e;
    }
  }
}
