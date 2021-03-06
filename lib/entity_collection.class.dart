part of 'main.dart';

class EntityCollection {

  Map<String, Entity> _allEntities;
  //Map<String, Entity> views;

  bool get isEmpty => _allEntities.isEmpty;
  List<Entity> get viewEntities => _allEntities.values.where((entity) => entity.isView).toList();

  EntityCollection() {
    _allEntities = {};
    //views = {};
  }

  bool get hasDefaultView => _allEntities.keys.contains("group.default_view");

  void parse(List rawData) {
    _allEntities.clear();
    //views.clear();

    Logger.d("Parsing ${rawData.length} Home Assistant entities");
    rawData.forEach((rawEntityData) {
      addFromRaw(rawEntityData);
    });
    _allEntities.forEach((entityId, entity){
      if ((entity.isGroup) && (entity.childEntityIds != null)) {
        entity.childEntities = getAll(entity.childEntityIds);
      }
      /*if (entity.isView) {
        views[entityId] = entity;
      }*/
    });
  }

  Entity _createEntityInstance(rawEntityData) {
    switch (rawEntityData["entity_id"].split(".")[0]) {
      case 'sun': {
        return SunEntity(rawEntityData);
      }
      case "media_player": {
        return MediaPlayerEntity(rawEntityData);
      }
      case 'sensor': {
        return SensorEntity(rawEntityData);
      }
      case 'lock': {
        return LockEntity(rawEntityData);
      }
      case "automation":
      case "input_boolean":
      case "switch": {
        return SwitchEntity(rawEntityData);
      }
      case "light": {
        return LightEntity(rawEntityData);
      }
      case "group": {
        return GroupEntity(rawEntityData);
      }
      case "script":
      case "scene": {
        return ButtonEntity(rawEntityData);
      }
      case "input_datetime": {
        return DateTimeEntity(rawEntityData);
      }
      case "input_select": {
        return SelectEntity(rawEntityData);
      }
      case "input_number": {
        return SliderEntity(rawEntityData);
      }
      case "input_text": {
        return TextEntity(rawEntityData);
      }
      case "climate": {
        return ClimateEntity(rawEntityData);
      }
      case "cover": {
        return CoverEntity(rawEntityData);
      }
      case "fan": {
        return FanEntity(rawEntityData);
      }
      default: {
        return Entity(rawEntityData);
      }
    }
  }

  bool updateState(Map rawStateData) {
    if (isExist(rawStateData["entity_id"])) {
      updateFromRaw(rawStateData["new_state"] ?? rawStateData["old_state"]);
      return false;
    } else {
      addFromRaw(rawStateData["new_state"] ?? rawStateData["old_state"]);
      return true;
    }
  }

  void add(Entity entity) {
    _allEntities[entity.entityId] = entity;
  }

  void addFromRaw(Map rawEntityData) {
    Entity entity = _createEntityInstance(rawEntityData);
    _allEntities[entity.entityId] = entity;
  }

  void updateFromRaw(Map rawEntityData) {
    get("${rawEntityData["entity_id"]}")?.update(rawEntityData);
  }

  Entity get(String entityId) {
    return _allEntities[entityId];
  }

  List<Entity> getAll(List ids) {
    List<Entity> result = [];
    ids.forEach((id){
      Entity en = get(id);
      if (en != null) {
        result.add(en);
      }
    });
    return result;
  }

  bool isExist(String entityId) {
    return _allEntities[entityId] != null;
  }

  List<Entity> filterEntitiesForDefaultView() {
    List<Entity> result = [];
    List<Entity> groups = [];
    List<Entity> nonGroupEntities = [];
    _allEntities.forEach((id, entity){
      if (entity.isGroup && (entity.attributes['auto'] == null || (entity.attributes['auto'] && !entity.isHidden)) && (!entity.isView)) {
        groups.add(entity);
      }
      if (!entity.isGroup) {
        nonGroupEntities.add(entity);
      }
    });

    nonGroupEntities.forEach((entity) {
      bool foundInGroup = false;
      groups.forEach((groupEntity) {
        if (groupEntity.childEntityIds.contains(entity.entityId)) {
          foundInGroup = true;
        }
      });
      if (!foundInGroup) {
        result.add(entity);
      }
    });
    result.insertAll(0, groups);

    return result;
  }
}