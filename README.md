# Enginf Backend Service for ClientF

## Test

* `enginf.model.dart` 를 플러터의 Test 방시긍로 할 수 없는 두 가지 이유가 있다.
  * 첫째, `enginf.model.dart` 에서는 Firebase 접속이 필요한데, Unit test 에서는 Firebase 로 접속을 할 수 없다. 초기화가 안된다.
  * 둘째, --watch 옵션이 없어서 불편다.
* 그래서 테스트가 필요하면 `lib/main.dart` 에서 `testEnginfUser()`와 같이 호출 하면 된다.
* 참고로, 벡앤드 코드는 벡엔드에서 충분히 테스트가 되었다. 그래서 사실상 클라이언트에서 Unit test 를 할 필요는 없다.

예제)
``` dart
  Widget build(BuildContext context) {
    if (kDebugMode) {
      testEnginfUser();
    }
```
