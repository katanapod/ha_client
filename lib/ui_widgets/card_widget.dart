part of '../main.dart';

class CardWidget extends StatelessWidget {

  final HACard card;

  const CardWidget({
    Key key,
    this.card
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if ((card.linkedEntityWrapper!= null) && (card.linkedEntityWrapper.entity.isHidden)) {
      return Container(width: 0.0, height: 0.0,);
    }

    switch (card.type) {

      case CardType.entities: {
        return _buildEntitiesCard(context);
      }

      case CardType.glance: {
        return _buildGlanceCard(context);
      }

      case CardType.mediaControl: {
        return _buildMediaControlsCard(context);
      }

      case CardType.entityButton: {
        return _buildEntityButtonCard(context);
      }

      case CardType.horizontalStack: {
        if (card.childCards.isNotEmpty) {
          List<Widget> children = [];
          card.childCards.forEach((card) {
            if (card.getEntitiesToShow().isNotEmpty || card.showEmpty) {
              children.add(
                  Flexible(
                    fit: FlexFit.tight,
                    child: card.build(context),
                  )
              );
            }
          });
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        }
        return Container(height: 0.0, width: 0.0,);
      }

      case CardType.verticalStack: {
        if (card.childCards.isNotEmpty) {
          List<Widget> children = [];
          card.childCards.forEach((card) {
            children.add(
                card.build(context)
            );
          });
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: children,
          );
        }
        return Container(height: 0.0, width: 0.0,);
      }

      default: {
        if ((card.linkedEntityWrapper == null) && (card.entities.isNotEmpty)) {
          return _buildEntitiesCard(context);
        } else {
          return _buildUnsupportedCard(context);
        }
      }

    }
  }

  Widget _buildEntitiesCard(BuildContext context) {
    List<EntityWrapper> entitiesToShow = card.getEntitiesToShow();
    if (entitiesToShow.isEmpty && !card.showEmpty) {
      return Container(height: 0.0, width: 0.0,);
    }
    List<Widget> body = [];
    body.add(CardHeaderWidget(name: card.name));
    entitiesToShow.forEach((EntityWrapper entity) {
      if (!entity.entity.isHidden) {
        body.add(
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, Sizes.rowPadding, 0.0, Sizes.rowPadding),
              child: EntityModel(
                  entityWrapper: entity,
                  handleTap: true,
                  child: entity.entity.buildDefaultWidget(context)
              ),
            ));
      }
    });
    return Card(
        child: new Column(mainAxisSize: MainAxisSize.min, children: body)
    );
  }

  Widget _buildGlanceCard(BuildContext context) {
    List<EntityWrapper> entitiesToShow = card.getEntitiesToShow();
    if (entitiesToShow.isEmpty && !card.showEmpty) {
      return Container(height: 0.0, width: 0.0,);
    }
    List<Widget> rows = [];
    rows.add(CardHeaderWidget(name: card.name));

    List<Widget> result = [];
    int columnsCount = entitiesToShow.length >= card.columnsCount ? card.columnsCount : entitiesToShow.length;

    entitiesToShow.forEach((EntityWrapper entity) {
      result.add(
          FractionallySizedBox(
            widthFactor: 1/columnsCount,
            child: EntityModel(
                entityWrapper: entity,
                child: GlanceEntityContainer(
                  showName: card.showName,
                  showState: card.showState,
                ),
                handleTap: true
            ),
          )
      );
    });
    rows.add(
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, Sizes.rowPadding, 0.0, 2*Sizes.rowPadding),
          child: Wrap(
            //alignment: WrapAlignment.spaceAround,
            runSpacing: Sizes.rowPadding*2,
            children: result,
          ),
        )
    );

    return Card(
        child: new Column(mainAxisSize: MainAxisSize.min, children: rows)
    );
  }

  Widget _buildMediaControlsCard(BuildContext context) {
    if (card.linkedEntityWrapper == null || card.linkedEntityWrapper.entity == null) {
      return Container(width: 0, height: 0,);
    } else {
      return Card(
          child: EntityModel(
              entityWrapper: card.linkedEntityWrapper,
              handleTap: null,
              child: MediaPlayerWidget()
          )
      );
    }
  }

  Widget _buildEntityButtonCard(BuildContext context) {
    if (card.linkedEntityWrapper == null || card.linkedEntityWrapper.entity == null) {
      return Container(width: 0, height: 0,);
    } else {
      card.linkedEntityWrapper.displayName = card.name?.toUpperCase() ??
          card.linkedEntityWrapper.displayName.toUpperCase();
      return Card(
          child: EntityModel(
              entityWrapper: card.linkedEntityWrapper,
              child: ButtonEntityContainer(),
              handleTap: true
          )
      );
    }
  }

  Widget _buildUnsupportedCard(BuildContext context) {
    List<Widget> body = [];
    body.add(CardHeaderWidget(name: card.name ?? ""));
    List<Widget> result = [];
    if (card.linkedEntityWrapper != null) {
      result.addAll(<Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, Sizes.rowPadding, 0.0, Sizes.rowPadding),
          child: EntityModel(
              entityWrapper: card.linkedEntityWrapper,
              handleTap: true,
              child: card.linkedEntityWrapper.entity.buildDefaultWidget(context)
          ),
        )
      ]);
    } else {
      result.addAll(<Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, Sizes.rowPadding),
          child: Text("'${card.type}' card is not supported yet"),
        ),
      ]);
    }
    body.addAll(result);
    return Card(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: body
        )
    );
  }

}