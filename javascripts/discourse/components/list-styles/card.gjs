import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import PluginOutlet from "discourse/components/plugin-outlet";
import BulkSelectCheckbox from "discourse/components/topic-list/bulk-select-checkbox";
import TopicExcerpt from "discourse/components/topic-list/topic-excerpt";
import TopicLink from "discourse/components/topic-list/topic-link";
import UnreadIndicator from "discourse/components/topic-list/unread-indicator";
import TopicPostBadges from "discourse/components/topic-post-badges";
import TopicStatus from "discourse/components/topic-status";
import lazyHash from "discourse/helpers/lazy-hash";
import { categoryLinkHTML } from "discourse/ui-kit/helpers/d-category-link";
import dFormatDate from "discourse/ui-kit/helpers/d-format-date";
import dNumber from "discourse/ui-kit/helpers/d-number";
import { i18n } from "discourse-i18n";
import { resolveActiveRule } from "../../lib/list-styles";
import TopicThumbnail from "./topic-thumbnail";

export default class Card extends Component {
  get showExcerpt() {
    return resolveActiveRule(getOwner(this)).show_excerpt;
  }

  @action
  onTitleFocus(event) {
    event.target.closest(".topic-list-item").classList.add("selected");
  }

  @action
  onTitleBlur(event) {
    event.target.closest(".topic-list-item").classList.remove("selected");
  }

  <template>
    <td class="list-styles-card">
      {{#if @bulkSelectEnabled}}
        <BulkSelectCheckbox
          @topic={{@topic}}
          @isSelected={{@isSelected}}
          @onToggle={{@onBulkSelectToggle}}
          class="list-styles-card__bulk-select"
        />
      {{/if}}

      <div class="list-styles-card__image">
        <TopicThumbnail @topic={{@topic}} />
      </div>

      {{#unless @hideCategory}}
        <div class="list-styles-card__badge">
          {{categoryLinkHTML @topic.category}}
        </div>
      {{/unless}}

      <div class="list-styles-card__title" role="heading" aria-level="2">
        <TopicStatus @topic={{@topic}} @context="topic-list" />
        <TopicLink
          {{on "focus" this.onTitleFocus}}
          {{on "blur" this.onTitleBlur}}
          @topic={{@topic}}
          class="raw-link raw-topic-link"
        />
        <PluginOutlet
          @name="topic-list-after-title"
          @outletArgs={{lazyHash topic=@topic}}
        />
        <UnreadIndicator @topic={{@topic}} />
        <TopicPostBadges
          @unreadPosts={{@topic.unread_posts}}
          @unseen={{@topic.unseen}}
          @url={{@topic.lastUnreadUrl}}
        />
      </div>

      {{#if this.showExcerpt}}
        <TopicExcerpt @topic={{@topic}} />
      {{/if}}

      <div class="list-styles-card__meta">
        <span class="list-styles-card__replies">
          {{dNumber @topic.replyCount}}
          {{i18n "replies_lowercase" count=@topic.replyCount}}
        </span>
        <span class="list-styles-card__views">
          {{dNumber @topic.views}}
          {{i18n "views_lowercase" count=@topic.views}}
        </span>
        <a class="list-styles-card__activity" href={{@topic.lastPostUrl}}>
          {{dFormatDate @topic.bumpedAt format="tiny" noTitle="true"}}
        </a>
      </div>
    </td>
  </template>
}
