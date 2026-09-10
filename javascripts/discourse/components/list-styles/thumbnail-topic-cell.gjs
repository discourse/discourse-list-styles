import { on } from "@ember/modifier";
import PluginOutlet from "discourse/components/plugin-outlet";
import ActionList from "discourse/components/topic-list/action-list";
import TopicCell from "discourse/components/topic-list/item/topic-cell";
import NewRepliesDot from "discourse/components/topic-list/new-replies-dot";
import ParticipantGroups from "discourse/components/topic-list/participant-groups";
import TopicExcerpt from "discourse/components/topic-list/topic-excerpt";
import TopicLink from "discourse/components/topic-list/topic-link";
import UnreadIndicator from "discourse/components/topic-list/unread-indicator";
import TopicPostBadges from "discourse/components/topic-post-badges";
import TopicStatus from "discourse/components/topic-status";
import lazyHash from "discourse/helpers/lazy-hash";
import topicFeaturedLink from "discourse/helpers/topic-featured-link";
import dCategoryLink from "discourse/ui-kit/helpers/d-category-link";
import dDiscourseTags from "discourse/ui-kit/helpers/d-discourse-tags";
import TopicThumbnail from "./topic-thumbnail";

// Core's topic cell with a thumbnail in front of the title. Replaces the
// `topic` column only for discovery lists resolved to the thumbnails style,
// so lists rendered elsewhere on the page (theme blocks, embedded
// BasicTopicList) stay untouched. Mirrors core's topic-cell template; keep it
// in sync when core changes.
export default class ThumbnailTopicCell extends TopicCell {
  <template>
    <td class="main-link topic-list-data" colspan="1">
      <TopicThumbnail @topic={{@topic}} />

      <PluginOutlet
        @name="topic-list-before-link"
        @outletArgs={{lazyHash topic=@topic}}
      />

      <span class="link-top-line" role="heading" aria-level="2">
        {{~! no whitespace ~}}
        <PluginOutlet
          @name="topic-list-before-status"
          @outletArgs={{lazyHash topic=@topic}}
        />
        {{~! no whitespace ~}}
        <PluginOutlet
          @name="topic-list-topic-cell-link-top-line"
          @outletArgs={{lazyHash topic=@topic tagsForUser=@tagsForUser}}
        >
          {{~! no whitespace ~}}
          <TopicStatus @topic={{@topic}} @context="topic-list" />
          {{~! no whitespace ~}}
          <TopicLink
            {{on "focus" this.onTitleFocus}}
            {{on "blur" this.onTitleBlur}}
            @topic={{@topic}}
            class="raw-link raw-topic-link"
          />
          {{~#if @topic.featured_link~}}
            &nbsp;
            {{~topicFeaturedLink @topic}}
          {{~/if~}}
          <PluginOutlet
            @name="topic-list-after-title"
            @outletArgs={{lazyHash topic=@topic}}
          />
          {{~! no whitespace ~}}
          <UnreadIndicator @topic={{@topic}} />
          {{~#if @topic.is_nested_view~}}
            {{~#if @topic.has_new_replies~}}
              <NewRepliesDot @topic={{@topic}} />
            {{~/if~}}
          {{~else if @showTopicPostBadges~}}
            <TopicPostBadges
              @unreadPosts={{@topic.unread_posts}}
              @unseen={{@topic.unseen}}
              @url={{@topic.lastUnreadUrl}}
            />
          {{~/if~}}
          <PluginOutlet
            @name="topic-list-after-badges"
            @outletArgs={{lazyHash topic=@topic}}
          />
        </PluginOutlet>
      </span>

      <div class="link-bottom-line">
        <PluginOutlet
          @name="topic-list-topic-cell-link-bottom-line"
          @outletArgs={{lazyHash topic=@topic tagsForUser=@tagsForUser}}
        >
          <PluginOutlet
            @name="topic-list-before-category"
            @outletArgs={{lazyHash topic=@topic}}
          />
          {{#unless @hideCategory}}
            {{#unless @topic.isPinnedUncategorized}}
              {{dCategoryLink @topic.category}}
            {{/unless}}
          {{/unless}}
          <PluginOutlet
            @name="topic-list-after-category"
            @outletArgs={{lazyHash topic=@topic}}
          />

          {{dDiscourseTags @topic mode="list" tagsForUser=@tagsForUser}}

          {{#if this.participantGroups}}
            <ParticipantGroups @groups={{this.participantGroups}} />
          {{/if}}

          <ActionList
            @topic={{@topic}}
            @postNumbers={{@topic.liked_post_numbers}}
            @icon="heart"
            class="likes"
          />
        </PluginOutlet>
      </div>

      {{#if @expandPinned}}
        <TopicExcerpt @topic={{@topic}} />
      {{/if}}

      <PluginOutlet
        @name="topic-list-main-link-bottom"
        @outletArgs={{lazyHash topic=@topic expandPinned=@expandPinned}}
      />
    </td>
  </template>
}
