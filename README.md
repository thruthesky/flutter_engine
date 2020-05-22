# Flutter Engine

* `Engine` 을 활용하여 플러터 앱을 제작하기 위한 라이브러리 모듈이다.

## 설치

### Git submodule 을 프로젝트에 추가

플터러 프로젝트 폴더에서 아래의 명령을 하면 된다.

```
git submodule add https://github.com/thruthesky/flutter_engine lib/flutter_engine
```

### 플러터 프로젝트에 Firebase 설정

* 주의: 다른 프로젝트의 GoogleService-Info.plist 를 복사하면 Bundle ID 가 틀려서 안된다.
  * 반드시 Firebase 에 새로운 앱을 등록하고 그 serivice key 파일을 받아야 한다.

### 익명 아이콘 설정

* `flutter_engine/assets/images/user-icon.png` 를 `assets`에 추가를 해 주어야 한다.
  * 주의: 폴더 경로가 다르면, 위치를 적절하게 수정 해 주어야 한다.

``` yml
flutter:
  assets:
    - lib/flutter_engine/assets/images/user-icon.png
```


### 패키지 설치

### iOS Info.plsit 수정

* 필요한 정보를 적절하게 추가한다.
* `<key>CFBundleLocalizations</key>`는 언어화에 필요한 것이다.

``` xml
	<key>CFBundleLocalizations</key>
	<array>
		<string>en</string>
		<string>ko</string>
		<string>ja</string>
		<string>zh</string>
	</array>
	
	<key>NSCameraUsageDescription</key>
	<string>This app requires access to the Camera to take images for posting on its forum and updating user profile.</string>
	<key>NSMicrophoneUsageDescription</key>
	<string>This app requires access to the microphone.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>This app requires access to the Photo Library to display images</string>
	<key>NSContactsUsageDescription</key>
	<string>This app requires access to the Contact.</string>
```

## 기본 코딩

* `Engine` 을 바탕으로 기본 코딩을 해 놓은 [플러터 Engine Client](https://github.com/thruthesky/clientf) 를 참고한다.

* 앱에서 아래와 같이 초기화를 한다.
  * `ef` 는 engine.globals.dart 에 정의 되어 전체 앱에서 사용된다.

``` dart
ef = EngineModel(
	navigatorKey: AppService.navigatorKey,
	onError: (e) => AppService.alert(null, t(e)),
);
```

* 그리고 `ef` 를 Provider 로 등록한다.

``` dart
MultiProvider(
	providers: [
		ChangeNotifierProvider(create: (context) => app),
		ChangeNotifierProvider(create: (context) => ef),
	],
```



## 수정과 삭제 용어

* 수정과 삭제를 한페이지 또는 기능 하나로 같이 하는 경우 함수명이나 코드에 `Edit` 이라는 용어를 쓴다.
* 수정만 하는 경우 함수명이나 코드에 `Update` 이라고 쓴다. 다만, 수정이라도 랜더링 화면에는 `Edit`으로 표기 될 수 있다.
* 글 생성하는 경우 `Create` 이라고 쓴다.
* 댓글 생성하는 경우 `Reply` 라고 쓴다.
* 그리고 편의를 위해서 Route 에는 Create 또는 Edit 이라고 쓰고 실제로 Edit 페이지로 이동하게 해도 된다.

## Test

* `enginf.model.dart` 를 플러터의 Test 방식로 할 수 없는 두 가지 이유가 있다.
  * 첫째, `enginf.model.dart` 에서는 Firebase 접속이 필요한데, Unit test 에서는 Firebase 로 접속을 할 수 없다. 초기화가 안된다.
  * 둘째, --watch 옵션이 없어서 불편다.
* 그래서 테스트가 필요하면 `lib/main.dart` 에서 `testEngineUser()`와 같이 호출 하면 된다.
* 참고로, 벡앤드 코드는 벡엔드에서 충분히 테스트가 되었다. 그래서 사실상 클라이언트에서 Unit test 를 할 필요는 없다.

예제)
``` dart
  Widget build(BuildContext context) {
    if (kDebugMode) {
      testEngineUser();
    }
```
