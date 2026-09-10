import HeaderTopicCell from "discourse/components/topic-list/header/topic-cell";
import { apiInitializer } from "discourse/lib/api";
import Card from "../components/list-styles/card";
import MobileRow from "../components/list-styles/mobile-row";
import StyleSelector from "../components/list-styles/style-selector";
import ThumbnailTopicCell from "../components/list-styles/thumbnail-topic-cell";
import {
  CARD_GRID,
  resolveActiveRule,
  THUMBNAIL_LIST,
} from "../lib/list-styles";

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
  function activeRule(context) {
    if (context.listContext !== "discovery") {
      return null;
    }

    return resolveActiveRule(api.container, { category: context.category });
  }

  api.renderInOutlet("before-create-topic-button", StyleSelector);

  api.registerValueTransformer("topic-list-class", ({ value, context }) => {
    const rule = activeRule(context);
    if (rule) {
      value.push("list-styles", `--${rule.style}`);
    }
    return value;
  });

  const site = api.container.lookup("service:site");

  function replaceColumns(columns, name, item) {
    CORE_COLUMNS.forEach((key) => {
      if (columns.has(key)) {
        columns.delete(key);
      }
    });
    columns.add(name, { header: HeaderTopicCell, item });
  }

  api.registerValueTransformer(
    "topic-list-columns",
    ({ value: columns, context }) => {
      const rule = activeRule(context);

      if (rule?.style === CARD_GRID) {
        replaceColumns(columns, "list-styles-card", Card);
      } else if (rule && site.mobileView) {
        replaceColumns(columns, "list-styles-mobile-row", MobileRow);
      } else if (rule?.style === THUMBNAIL_LIST) {
        columns.replace("topic", { item: ThumbnailTopicCell });
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
      if (activeRule(context)) {
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
