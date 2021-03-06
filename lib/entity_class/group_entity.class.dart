part of '../main.dart';

class GroupEntity extends Entity {
  GroupEntity(Map rawData) : super(rawData);

  final List<String> _domainsForSwitchableGroup = ["switch", "light", "automation", "input_boolean"];
  String mutualDomain;
  bool switchable = false;

  @override
  Widget _buildStatePart(BuildContext context) {
    if (switchable) {
      return SwitchStateWidget(
        domainForService: "homeassistant",
      );
    } else {
      return super._buildStatePart(context);
    }
  }

  @override
  void update(Map rawData) {
    super.update(rawData);
    if (_isOneDomain()) {
      mutualDomain = attributes['entity_id'][0].split(".")[0];
      switchable = _domainsForSwitchableGroup.contains(mutualDomain);
    }
  }

  bool _isOneDomain() {
    bool result = false;
    if (attributes['entity_id'] != null && attributes['entity_id'] is List && attributes['entity_id'].isNotEmpty) {
      String firstChildDomain = attributes['entity_id'][0].split(".")[0];
      result = true;
      attributes['entity_id'].forEach((childEntityId){
        if (childEntityId.split(".")[0] != firstChildDomain) {
          result = false;
        }
      });
    }
    return result;
  }
}