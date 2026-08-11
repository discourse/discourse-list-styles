import HeaderTopicCell from "discourse/components/topic-list/header/topic-cell";
import { apiInitializer } from "discourse/lib/api";
import Card from "../components/list-styles/card";
import RowThumbnail from "../components/list-styles/row-thumbnail";
import StyleSelector from "../components/list-styles/style-selector";
import { CARD_GRID, overrideStyleFor, resolveRule } from "../lib/list-styles";

const CORE_COLUMNS = [
  "bulk-select",
  "topic",
  "posters",
  "replies",
  "likes",
  "op-likes",
  "views",
  "activity",
];

export default apiInitializer((api) => {
  const discovery = api.container.lookup("service:discovery");
  const router = api.container.lookup("service:router");
  const override = api.container.lookup("service:list-style-override");

  function activeRule(context) {
    if (context.listContext !== "discovery") {
      return null;
    }

    const category = context.category ?? discovery.category;
    const tag = discovery.tag;

    return resolveRule({
      category,
      tag,
      forcedStyle: router.currentRoute?.metadata?.customTopicListStyle,
      overrideStyle: overrideStyleFor(override, { category, tag }),
    });
  }

  api.renderInOutlet("topic-list-before-link", RowThumbnail);
  api.renderInOutlet("before-create-topic-button", StyleSelector);

  api.registerValueTransformer("topic-list-class", ({ value, context }) => {
    const rule = activeRule(context);
    if (rule) {
      value.push("list-styles", `--${rule.style}`);
    }
    return value;
  });

  api.registerValueTransformer(
    "topic-list-columns",
    ({ value: columns, context }) => {
      if (activeRule(context)?.style === CARD_GRID) {
        CORE_COLUMNS.forEach((key) => {
          if (columns.has(key)) {
            columns.delete(key);
          }
        });
        columns.add("list-styles-card", {
          header: HeaderTopicCell,
          item: Card,
        });
      }
      return columns;
    }
  );

  api.registerValueTransformer(
    "topic-list-item-expand-pinned",
    ({ value, context }) => {
      if (activeRule(context)?.show_excerpt) {
        return true;
      }
      return value;
    }
  );

  api.registerValueTransformer(
    "topic-list-item-mobile-layout",
    ({ value, context }) => {
      if (activeRule(context)?.style === CARD_GRID) {
        return false;
      }
      return value;
    }
  );

  api.registerValueTransformer("bulk-select-in-nav-controls", () => true);

  api.registerBehaviorTransformer(
    "topic-list-item-click",
    ({ context, next }) => {
      const { event, listContext } = context;

      if (activeRule({ listContext })?.style !== CARD_GRID) {
        return next();
      }

      if (
        (event.target.closest("a, button, input") &&
          !event.target.closest(".topic-excerpt")) ||
        event.target.closest(".topic-excerpt-more")
      ) {
        return next();
      }

      event.preventDefault();
      event.stopPropagation();

      const topicLink = event.target
        .closest("tr")
        .querySelector("a.raw-topic-link");

      if (event.button === 1) {
        window.open(topicLink.href, "_blank", "noopener,noreferrer");
        return;
      }

      topicLink.dispatchEvent(
        new MouseEvent("click", {
          ctrlKey: event.ctrlKey,
          metaKey: event.metaKey,
          shiftKey: event.shiftKey,
          button: event.button,
          which: event.which,
          bubbles: true,
          cancelable: true,
        })
      );
    }
  );
});
