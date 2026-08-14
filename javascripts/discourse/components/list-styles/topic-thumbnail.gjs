import Component from "@glimmer/component";
import dConcatClass from "discourse/ui-kit/helpers/d-concat-class";
import dIcon from "discourse/ui-kit/helpers/d-icon";

const RESPONSIVE_RATIOS = [1, 1.5, 2];
const DISPLAY_WIDTH = 400;
const FALLBACK_WIDTH = 1110;

export default class TopicThumbnail extends Component {
  get topic() {
    return this.args.topic;
  }

  get hasThumbnail() {
    return !!this.topic.thumbnails;
  }

  get original() {
    return this.topic.thumbnails[0];
  }

  get srcSet() {
    const sources = [];

    RESPONSIVE_RATIOS.forEach((ratio) => {
      const match = this.topic.thumbnails.find(
        (t) => t.url && t.max_width === ratio * DISPLAY_WIDTH
      );
      if (match) {
        sources.push(`${match.url} ${ratio}x`);
      }
    });

    if (sources.length === 0) {
      sources.push(`${this.original.url} 1x`);
    }

    return sources.join(",");
  }

  get fallbackSrc() {
    const fallback = this.topic.thumbnails.find(
      (t) => t.url && t.max_width === FALLBACK_WIDTH
    );

    return (fallback ?? this.original).url;
  }

  get url() {
    return this.topic.linked_post_number
      ? this.topic.urlForPostNumber(this.topic.linked_post_number)
      : this.topic.lastUnreadUrl;
  }

  <template>
    <a
      href={{this.url}}
      class={{dConcatClass
        "list-styles-thumbnail"
        (if this.hasThumbnail "has-thumbnail" "no-thumbnail")
      }}
      aria-hidden="true"
      tabindex="-1"
    >
      {{#if this.hasThumbnail}}
        <img
          src={{this.fallbackSrc}}
          srcset={{this.srcSet}}
          width={{this.original.width}}
          height={{this.original.height}}
          loading="lazy"
          alt=""
        />
      {{else}}
        <div class="list-styles-thumbnail__placeholder">
          {{dIcon "far-comment"}}
        </div>
      {{/if}}
    </a>
  </template>
}
