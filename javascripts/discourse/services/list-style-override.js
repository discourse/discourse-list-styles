import { tracked } from "@glimmer/tracking";
import Service, { service } from "@ember/service";

export default class ListStyleOverride extends Service {
  @service keyValueStore;

  @tracked revision = 0;

  scopeFor({ category, tag }) {
    if (category) {
      return `c-${category.id}`;
    }
    if (tag) {
      return `t-${tag.id}`;
    }
    return "global";
  }

  styleFor(scope) {
    this.revision;
    return this.keyValueStore.get(`list-style-${scope}`) || null;
  }

  set(scope, style) {
    if (style) {
      this.keyValueStore.set({ key: `list-style-${scope}`, value: style });
    } else {
      this.keyValueStore.remove(`list-style-${scope}`);
    }
    this.revision++;
  }
}
