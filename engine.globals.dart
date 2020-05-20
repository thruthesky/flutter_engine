import 'package:clientf/services/app.service.dart';

///
/// `Engine` 에서 사용하는 글로벌 변수 몽므

import './engine.model.dart';


/// `Engine` `state model` 을 여기서 한번만 생성하여 글로벌 변수로 사용한다.
/// 글로벌 변수 명은 `ef` 이며, 이 값을 Provider 에 등록하면 되고, 필요하면 이 객체를 바로 사용하면 된다.
EngineModel ef = EngineModel(navigatorKey: AppService.navigatorKey);

