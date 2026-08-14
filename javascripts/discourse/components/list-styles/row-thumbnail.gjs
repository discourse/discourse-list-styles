import Component from "@glimmer/component";
import { getOwner } from "@ember/owner";
import { service } from "@ember/service";
import { resolveActiveRule, THUMBNAIL_LIST } from "../../lib/list-styles";
import TopicThumbnail from "./topic-thumbnail";

export default class RowThumbnail extends Component {
  @service discovery;

  get isActive() {
    if (!this.discovery.onDiscoveryRoute) {
      return false;
    }

    return resolveActiveRule(getOwner(this)).style === THUMBNAIL_LIST;
  }

  <template>
    {{#if this.isActive}}
      <TopicThumbnail @topic={{@outletArgs.topic}} />
    {{/if}}
  </template>
}
