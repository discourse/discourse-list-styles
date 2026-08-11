export const PLAIN = "plain";
export const THUMBNAIL_LIST = "thumbnail-list";
export const CARD_GRID = "card-grid";

const DEFAULT_RULE = { style: PLAIN, show_excerpt: true };

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
    return { ...DEFAULT_RULE, style: forcedStyle };
  }

  const matches = (rule) =>
    categoryMatches(rule, category) && tagMatches(rule, tag);

  const rule =
    settings.list_styles.find((r) => isScoped(r) && matches(r)) ??
    settings.list_styles.find((r) => !isScoped(r)) ??
    DEFAULT_RULE;

  if (overrideStyle) {
    return { ...rule, style: overrideStyle };
  }

  return rule;
}
