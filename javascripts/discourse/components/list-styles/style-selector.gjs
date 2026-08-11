import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DMenu from "discourse/float-kit/components/d-menu";
import { eq } from "discourse/truth-helpers";
import DButton from "discourse/ui-kit/d-button";
import DDropdownMenu from "discourse/ui-kit/d-dropdown-menu";
import dConcatClass from "discourse/ui-kit/helpers/d-concat-class";
import { i18n } from "discourse-i18n";
import {
  CARD_GRID,
  overrideStyleFor,
  PLAIN,
  resolveRule,
  THUMBNAIL_LIST,
} from "../../lib/list-styles";

const AUTO = "auto";

export default class StyleSelector extends Component {
  @service discovery;
  @service listStyleOverride;
  @service router;

  get shouldShow() {
    return (
      settings.allow_style_switching &&
      this.discovery.onDiscoveryRoute &&
      !this.router.currentRoute?.metadata?.customTopicListStyle
    );
  }

  get scope() {
    return this.listStyleOverride.scopeFor({
      category: this.discovery.category,
      tag: this.discovery.tag,
    });
  }

  get current() {
    return this.listStyleOverride.styleFor(this.scope) ?? AUTO;
  }

  get styles() {
    return [
      { id: PLAIN, icon: "far-rectangle-list", label: "selector.plain" },
      {
        id: THUMBNAIL_LIST,
        icon: "far-newspaper",
        label: "selector.thumbnails",
      },
      { id: CARD_GRID, icon: "far-images", label: "selector.cards" },
    ];
  }

  get triggerIcon() {
    const scopeArgs = {
      category: this.discovery.category,
      tag: this.discovery.tag,
    };

    const effectiveStyle = resolveRule({
      ...scopeArgs,
      overrideStyle: overrideStyleFor(this.listStyleOverride, scopeArgs),
    }).style;

    return this.styles.find((s) => s.id === effectiveStyle)?.icon ?? "sliders";
  }

  get defaultStyle() {
    return { id: AUTO, icon: "arrows-rotate", label: "selector.default" };
  }

  @action
  onRegisterApi(api) {
    this.dMenu = api;
  }

  @action
  select(styleId) {
    this.listStyleOverride.set(this.scope, styleId === AUTO ? null : styleId);
    this.dMenu?.close();
  }

  <template>
    {{#if this.shouldShow}}
      <DMenu
        @identifier="list-style-selector"
        @icon={{this.triggerIcon}}
        @title={{i18n (themePrefix "selector.title")}}
        @onRegisterApi={{this.onRegisterApi}}
        class="btn-default list-style-selector"
      >
        <:content>
          <DDropdownMenu as |dropdown|>
            {{#each this.styles as |style|}}
              <dropdown.item>
                <DButton
                  @icon={{style.icon}}
                  @label={{themePrefix style.label}}
                  @action={{fn this.select style.id}}
                  class={{dConcatClass
                    "btn-transparent list-style-selector__option"
                    (if (eq this.current style.id) "--active")
                  }}
                />
              </dropdown.item>
            {{/each}}

            <dropdown.divider />

            <dropdown.item>
              <DButton
                @icon={{this.defaultStyle.icon}}
                @label={{themePrefix this.defaultStyle.label}}
                @action={{fn this.select this.defaultStyle.id}}
                class={{dConcatClass
                  "btn-transparent list-style-selector__option"
                  (if (eq this.current this.defaultStyle.id) "--active")
                }}
              />
            </dropdown.item>
          </DDropdownMenu>
        </:content>
      </DMenu>
    {{/if}}
  </template>
}
