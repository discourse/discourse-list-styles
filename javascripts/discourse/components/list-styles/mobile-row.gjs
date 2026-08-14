import Component from "@glimmer/component";
import { getOwner } from "@ember/owner";
import BulkSelectCheckbox from "discourse/components/topic-list/bulk-select-checkbox";
import TopicExcerpt from "discourse/components/topic-list/topic-excerpt";
import TopicLink from "discourse/components/topic-list/topic-link";
import UnreadIndicator from "discourse/components/topic-list/unread-indicator";
import TopicPostBadges from "discourse/components/topic-post-badges";
import TopicStatus from "discourse/components/topic-status";
import DUserLink from "discourse/ui-kit/d-user-link";
import dAvatar from "discourse/ui-kit/helpers/d-avatar";
import dCategoryLink from "discourse/ui-kit/helpers/d-category-link";
import dConcatClass from "discourse/ui-kit/helpers/d-concat-class";
import dDiscourseTags from "discourse/ui-kit/helpers/d-discourse-tags";
import dFormatDate from "discourse/ui-kit/helpers/d-format-date";
import { i18n } from "discourse-i18n";
import { resolveActiveRule, THUMBNAIL_LIST } from "../../lib/list-styles";
import TopicThumbnail from "./topic-thumbnail";

export default class MobileRow extends Component {
  get showThumbnail() {
    return resolveActiveRule(getOwner(this)).style === THUMBNAIL_LIST;
  }

  <template>
    <td
      class={{dConcatClass
        "list-styles-mobile-row"
        (if this.showThumbnail "--has-thumbnail")
      }}
    >
      {{#if this.showThumbnail}}
        <div class="list-styles-mobile-row__image">
          <TopicThumbnail @topic={{@topic}} />
        </div>
      {{/if}}

      <div class="list-styles-mobile-row__avatar">
        {{#if @bulkSelectEnabled}}
          <BulkSelectCheckbox
            @topic={{@topic}}
            @isSelected={{@isSelected}}
            @onToggle={{@onBulkSelectToggle}}
          />
        {{else}}
          <DUserLink
            @ariaLabel={{i18n
              "latest_poster_link"
              username=@topic.lastPosterUser.username
            }}
            @username={{@topic.lastPosterUser.username}}
          >
            {{dAvatar @topic.lastPosterUser imageSize="large"}}
          </DUserLink>
        {{/if}}
      </div>

      <div class="list-styles-mobile-row__content">
        <div class="list-styles-mobile-row__title">
          <TopicStatus @topic={{@topic}} @context="topic-list" />
          <TopicLink @topic={{@topic}} class="raw-link raw-topic-link" />
        </div>

        {{#if @expandPinned}}
          <TopicExcerpt @topic={{@topic}} />
        {{/if}}

        <div class="list-styles-mobile-row__meta">
          {{#unless @hideCategory}}
            {{dCategoryLink @topic.category}}
          {{/unless}}
          {{dDiscourseTags @topic mode="list"}}
        </div>
      </div>

      <div class="list-styles-mobile-row__side">
        <a class="list-styles-mobile-row__activity" href={{@topic.lastPostUrl}}>
          {{dFormatDate @topic.bumpedAt format="tiny" noTitle="true"}}
        </a>
        <div class="list-styles-mobile-row__badges">
          <UnreadIndicator @topic={{@topic}} />
          <TopicPostBadges
            @unreadPosts={{@topic.unread_posts}}
            @unseen={{@topic.unseen}}
            @url={{@topic.lastUnreadUrl}}
          />
        </div>
      </div>
    </td>
  </template>
}
