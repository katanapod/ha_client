part of '../main.dart';

class HomeAssistantUI {
  List<HAView> views;
  String title;

  HomeAssistantUI() {
    views = [];
  }

  Widget build(BuildContext context) {
    return TabBarView(
      children: _buildViews(context)
    );
  }

  List<Widget> _buildViews(BuildContext context) {
    List<Widget> result = [];
    views.forEach((view) {
      result.add(
        view.build(context)
      );
    });
    return result;
  }

}