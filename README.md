# List Styles

A theme component that adds three curated topic list styles and lets admins route them per category or tag.

## Styles

- **List** (`list-plain`): the component's base style for all discovery lists. Core columns, roomier rows, optional excerpts.
- **Thumbnails** (`list-thumbnails`): the plain list with a topic thumbnail beside each row.
- **Cards** (`grid-cards`): a responsive card grid with thumbnail, category badge, title, excerpt, and activity metadata.

## How it works

Admins define rules in the `list_style_rules` setting. A rule applies to the categories and tags it lists, and the first matching rule wins. Rules without categories or tags don't scope anything; they only appear as choices in the viewer style selector. Lists that no rule matches use `default_list_style`.

Users can override the configured style per category or tag through a selector in the list controls (disable with `allow_style_switching`). Their choice is stored in the browser.

## TODO

- **Grid mode a11y roles.** Cards mode restyles core's topic list table with `display: grid`, which leaves screen readers announcing stale or missing table semantics. The clean fix is a core transformer for topic list attributes (e.g. `topic-list-roles`) so themes can set `role="presentation"` on the table and `list`/`listitem` on body and rows declaratively. Until that exists, the alternative is an element modifier on the card cell that sets roles on its ancestors.
- **Rule icons need an icon picker.** Add the new icon picker from core
