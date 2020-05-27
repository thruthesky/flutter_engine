# Flutter Engine

* `Flutter Engine`은 파이어베이스 기반 백엔드인 `Engine` 을 활용하여 플러터 앱을 제작하기 위한 라이브러리 모듈이다.
* `callback` 브랜치를 보면, `Flutter Engine` 에서 게시판 관련 기능을 구현 할 때, state 관리 없이 callback 으로만 되어져 있는 것을 볼 수 있다.
* 처음에 `Provider`를 바탕으로 개발을 하였다가 모든 개발자들이 `Provider`를 쓰는 것이 아니라는 생각에 `callback` 으로 제작하게 되었는데, callback hell 이 나타나는 조짐이 보여서 다시 `Provider`를 기반으로 만들게 되었다.

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

* 그리고 `ef` 를 main.dart 에서 전체 영역으로 Provider 등록한다.
  * 회원 로그인 및 정보를 state 로 관리하며, 앱 전체 영역으로 해야, 전체 영역에서 회원 state 정보를 업데이트 할 수 있다.

``` dart
MultiProvider(
	providers: [
		ChangeNotifierProvider(create: (context) => ef),
	],
```

* 게시판 state 는 해당 게시판 별로 별도의 Model 객체를 생성해서 Provider 등록하면 된다.


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

## 캐시를 하는 경우 수정, 삭제

* 게시글 목록을 캐시를 하면, 캐시된 글의 목록을 먼저 보여 주고, 그 다음 서버에서 데이터를 가져와 `this.posts` 에 덮어 쓴다.
* 이 때, 서버에서 데이터를 가져오기 전에( 앱 부팅 후 빠르게 ), 글 수정, 코멘트 작성/수정 하면, 수정 폼으로 캐시된 `this.posts` 의 `post` 를 reference 로 전달하고,
* 수정(작성) 된 후, 작성된 글(코멘트)를 업데이트 할 때, 캐시된 `post` reference 를 바탕으로 하게된다.
* 즉, `앱 부팅 -> 캐시 목록 -> 글 수정 폼 -> 백엔드로 부터 실제 데이터 로드 -> 글 수정 완료 -> 캐시된 데이터 수정` 과 같은 단계로 진행되어
* 수정을 한 다음에는 화면에 `실제 데이터` 가 보이는데,
* 수정을 한 결과를 이미 화면에서 사라진 캐시된 목록의 `this.posts` 에 있는 `post` reference 에 하는 문제가 발생한다.
* 그래서, 글 수정, 코멘트 작성, 수정시 `EngineModel.posts` 를 바탕으로 항상 업데이틀 한다.
* 이와 같은 문제는 글/코멘트 삭제를 할 때에도 발생 할 수 있다. 하지만 글/코멘트 삭제를 할 때에는 그냥 내버려 두낟.


## Named route 지정

* 글 생성, 수정 후 이동해야 핦 페이지를 `Engine`에서 임의로 라우터로 이동하면, 범용적이지 못하게된다.
* 하지만 `Engine` 에서 직접 라우트를 이동하지 않으면 코드가 복잡해진다.
  * 회원 가입이나 로그인 등은 작업 결과를 callback handler 로 받아 앱 메인 코드에서 처리해도 충분히 코드가 간결하다.
  * 하지만, 게시판 목록 => 게시글 읽기 => 글 수정 등 여러 단계로 라우트가 이동을 해야하거나 구조가 복잡한 경우, callback handler 로 하기에는 복잡하다. `callback hell` 이 나타난다.
* 그래서 `EngineRoute` 에 Named Route 를 지정하여, 앱의 Named route 와 일치하게 조정한다.
  * `Engine` 에서 글(코멘트) 작성/수정 등의 작업 후에 지정된 named route 로 이동을 한다.
* Engine 의 Named route 는 `engine.defiens.dart`에 지정되어져 있는데,
  * 앱의 글 목록 named route 가 `postList` 라면, Engine route 에도 동일하게 `postList` 로 해 주어서, 글 작성 후 Engine 에서 바로 `postList` 라우트로 이동을 하면 되는 것이다.




## 예제

### EngineForumListModel.init()

* `EngineForumListModel` 은 하나의 게시판(카테고리)을 목록하기 위한 것이다.
  * 여러 카테고리를 한 꺼번에 목록하는 것은 코드의 수정이 필요하다.
* `EngineForumListModel` 로 게시판(카테고리)목록이 아닌 최근 글 목록을 위해서 사용 할 수 있다.
  * 이 때, 'Provider 로 state 를 관리하지 않고' 게시판 카테고리의 첫번째 글을 가져와 `setState()` 로 업데이트 할 수 있다.

``` dart
@override
void initState() {
  (() async {
    await forum.init(
      id: widget.id,
      cacheKey: 'front-page-7',
      limit: 15,
    );
    setState(() => null);
  })();
  super.initState();
}
```


### 여러개의 카테고리로 부터 글 가져오기

* 예제 1)

``` dart
@override
void initState() {
  Timer(
    Duration(milliseconds: 100),
    () async {
      posts = await ef.postList({'categories': widget.categories});
      if (!mounted) return;
      setState(() => null);
    },
  );
  super.initState();
}
```

* 예제 2)

``` dart
class ... extends State<EngineLatestPosts> {
  final EngineForumListModel forum = EngineForumListModel();

  @override
  void initState() {
    Timer(
      Duration(milliseconds: 100),
      () async {
        await forum.init(
          categories: ['qna', 'discussion'],
          cacheKey: EngineCacheKey.frontPage(''),
          limit: 15,
          onLoad: (posts) {
            if (mounted) setState(() => null);
          },
        );
      },
    );
    super.initState();
  }
```


## 알려진 문제점

### 성능 문제

* `Clould Functions` 자체가 느리다. 특히 K8s 나 AWS Lamda 와 많이 비교되고 있는데, `Clould Functions`가 다른 것들에 비해서 월등히 느리다. 그리고 사용자가 확실히 체감 할 수 있을 정도로 느리다.
  * 그래서 서버를 사용자와 가까운 서버를 두는 것이 매우 중요하다.
  * 적어도 개발 중에 플러터 앱으로 테스트 할 때에는 매우 심각한 성능 저하 및 `Resources exhausted` 에러가 끊임 없이 발생하고 있다.
  * 그래서 성능을 일부 향상 시키기 위해서, `settings.ts` 에서 `

