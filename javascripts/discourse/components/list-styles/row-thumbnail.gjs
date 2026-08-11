import Component from "@glimmer/component";
import { service } from "@ember/service";
import {
  overrideStyleFor,
  resolveRule,
  THUMBNAIL_LIST,
} from "../../lib/list-styles";
import TopicThumbnail from "./topic-thumbnail";

export default class RowThumbnail extends Component {
  @service discovery;
  @service listStyleOverride;
  @service router;

  get isActive() {
    if (!this.discovery.onDiscoveryRoute) {
      return false;
    }

    const scope = {
      category: this.discovery.category,
      tag: this.discovery.tag,
    };

    const rule = resolveRule({
      ...scope,
      forcedStyle: this.router.currentRoute?.metadata?.customTopicListStyle,
      overrideStyle: overrideStyleFor(this.listStyleOverride, scope),
    });

    return rule.style === THUMBNAIL_LIST;
  }

  <template>
    {{#if this.isActive}}
      <TopicThumbnail @topic={{@outletArgs.topic}} />
    {{/if}}
  </template>
}
