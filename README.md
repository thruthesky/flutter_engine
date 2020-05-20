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

### 패키지 설치


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
