export const LIST = "list-plain";
export const THUMBNAIL_LIST = "list-thumbnails";
export const CARD_GRID = "grid-cards";

function defaultRule() {
  return { style: settings.default_style, show_excerpt: true };
}

function categoryMatches(rule, category) {
  if (!rule.categories?.length) {
    return true;
  }

  for (let c = category; c; c = c.parentCategory) {
    if (rule.categories.includes(c.id)) {
      return c === category || rule.include_subcategories;
    }
  }

  return false;
}

function tagMatches(rule, tag) {
  if (!rule.tags?.length) {
    return true;
  }

  return !!tag && rule.tags.includes(tag.id);
}

export const STYLE_ICONS = {
  [LIST]: "far-rectangle-list",
  [THUMBNAIL_LIST]: "far-newspaper",
  [CARD_GRID]: "far-images",
};

export function overrideStyleFor(overrideService, scopeArgs) {
  if (!settings.allow_style_switching) {
    return null;
  }
  return overrideService.styleFor(overrideService.scopeFor(scopeArgs));
}

function isScoped(rule) {
  return !!(rule.categories?.length || rule.tags?.length);
}

export function resolveRule({ category, tag, forcedStyle, overrideStyle }) {
  if (forcedStyle) {
    return { ...defaultRule(), style: forcedStyle };
  }

  const matches = (rule) =>
    categoryMatches(rule, category) && tagMatches(rule, tag);

  const rule =
    settings.list_styles.find((r) => isScoped(r) && matches(r)) ??
    defaultRule();

  if (overrideStyle) {
    return { ...rule, style: overrideStyle };
  }

  return rule;
}
