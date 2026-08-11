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
  overrideStyleFor,
  resolveRule,
  STYLE_ICONS,
} from "../../lib/list-styles";

const AUTO = "auto";

function iconFor(rule) {
  return rule.icon || STYLE_ICONS[rule.style] || "sliders";
}

export default class StyleSelector extends Component {
  @service discovery;
  @service listStyleOverride;
  @service router;

  get shouldShow() {
    return (
      settings.allow_style_switching &&
      this.discovery.onDiscoveryRoute &&
      !this.router.currentRoute?.metadata?.customTopicListStyle &&
      this.presetItems.length > 0
    );
  }

  get scopeArgs() {
    return {
      category: this.discovery.category,
      tag: this.discovery.tag,
    };
  }

  get scope() {
    return this.listStyleOverride.scopeFor(this.scopeArgs);
  }

  get current() {
    return this.listStyleOverride.styleFor(this.scope) ?? AUTO;
  }

  get presetItems() {
    const seen = new Set();

    return settings.list_styles
      .filter((rule) => !seen.has(rule.style) && seen.add(rule.style))
      .map((rule) => ({
        style: rule.style,
        label: rule.label,
        icon: iconFor(rule),
      }));
  }

  get resetItem() {
    return {
      label: i18n(themePrefix("selector.default")),
      icon: "arrows-rotate",
    };
  }

  get triggerIcon() {
    const overrideStyle = overrideStyleFor(
      this.listStyleOverride,
      this.scopeArgs
    );

    if (overrideStyle) {
      const preset = this.presetItems.find((p) => p.style === overrideStyle);
      return preset?.icon ?? STYLE_ICONS[overrideStyle] ?? "sliders";
    }

    return iconFor(resolveRule(this.scopeArgs));
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
            {{#each this.presetItems as |item|}}
              <dropdown.item>
                <DButton
                  @icon={{item.icon}}
                  @translatedLabel={{item.label}}
                  @action={{fn this.select item.style}}
                  class={{dConcatClass
                    "btn-transparent list-style-selector__option"
                    (if (eq this.current item.style) "--active")
                  }}
                />
              </dropdown.item>
            {{/each}}

            <dropdown.divider />

            <dropdown.item>
              <DButton
                @icon={{this.resetItem.icon}}
                @translatedLabel={{this.resetItem.label}}
                @action={{fn this.select "auto"}}
                class={{dConcatClass
                  "btn-transparent list-style-selector__option"
                  (if (eq this.current "auto") "--active")
                }}
              />
            </dropdown.item>
          </DDropdownMenu>
        </:content>
      </DMenu>
    {{/if}}
  </template>
}
