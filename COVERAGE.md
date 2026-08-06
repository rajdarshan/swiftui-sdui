# Component coverage

**~60% coverage of the home screen's major layouts.** That's a conservative
read, not a literal count — the pattern table below shows 9 of 12 distinct
homepage sections match a container/item type in the registry exactly, which
is 75% by raw presence. The headline is held lower than that because
matching container *type* doesn't guarantee full field- and style-level
fidelity within the match (exact spacing, edge-case props, token parity
against the live site aren't independently re-verified item by item here) —
so read 60% as "most of the major layouts are handled, with real gaps," and
the table as the evidence to check that against yourself.

## Home page: pattern by pattern

| # | Cars24 homepage section | Schema fit |
|---|---|---|
| 1 | Header — location pill, search field, 7-tab strip | **Match** — `header` type, `COMPONENTS.md` §9 |
| 2 | "Buy car" rail + "Up to ₹80,000 off" badge | **Match** — `rail` of `tile`, `Header.badge` |
| 3 | "Sell your car" rail | **Match** — `rail` of `tile` |
| 4 | "Get loans" rail | **Match** — `rail` of `iconTile` |
| 5 | "Car check services" grid | **Match** — `grid`, 2–4 configurable columns |
| 6 | "Manage your vehicle" grid, brand-colored band | **Match** — `grid` + `style.background` |
| 7 | "Trending new cars" rail + "View all" link | **Match** — `rail` of `modelCard`, `Header.trailing` button |
| 8 | Promo carousel banner (e.g. an EV trade-in offer) | **Match** — `carousel`/`single` of `promoCard` |
| 9 | App-download promo banner | **Match** — `single` of `promoCard` |
| 10 | Reviewer testimonial rail — avatar, name, context line ("bought used car · date"), quote | **Gap** — no item type carries avatar + name + timestamp + quote as distinct fields |
| 11 | Trust/stats banner — rating, review count, multiple stat numbers over a background photo | **Gap** — `promoCard` has no repeating stat-number/label layout |
| 12 | Footer — grouped link columns (company/discover/support/social), country list, corporate address | **Gap** — `textBlock` is one title+subtitle block, not a grouped link directory |

9/12 sections match cleanly. The 3 gaps cluster in one place: **rich,
content-heavy trust/marketing sections** (testimonials, stats, footer) — not
scattered across the core commerce layouts (rails, grids, promos), which is
exactly where the schema was designed hardest.

## What the schema can express — by pattern category

Grounded in `COMPONENTS.md` §4, §6–§8:

- **Lists** — `rail` (horizontal, `snap`/`itemWidth` peek ratios) and `list`
  (vertical; defined in the schema, unused on this particular screen).
- **Grids** — `grid`, fixed 2–4 columns, equal row heights, no laziness (by
  design — see `README.md`'s Trade-offs).
- **Conditionals** — two mechanisms, both narrow: `filter` (chip-based,
  single active dataset per section, `COMPONENTS.md` §7) and the fallback
  rules (unknown type or missing mandatory prop → try `fallback`, else
  skip). There's no general if/then, no user-attribute branching, and no
  A/B variant selection — this is a real limit, not just an unused feature.
- **Actions** — the `Action` value object, 8 `type`s (`navigate`,
  `openSheet`, `toggle`, `call`, `openMaps`, `openUrl`, `search`, and the
  reserved `select`), always dispatched through `ActionHandler`.
- **Styling overrides** — the `Style` value object, token-only
  (`background`/`foreground`/`border`/`cornerRadius`), plus `Badge` and
  `Button` variants. No raw hex/point values, and no arbitrary per-instance
  overrides outside the token set — a payload can pick a different token,
  never invent a value.

## The 3 gaps, if this were extended

Named as what they'd be, not as a commitment to build them:

- A **review/testimonial card** item type — avatar image, name, a short
  context line, and a quote body, distinct from `featureCard`'s
  headline+body shape.
- A **stats banner** — a promo-like section that can lay out several
  number+label pairs together, which `promoCard` doesn't support today.
- A **grouped link footer** container — multiple labeled columns of links,
  a structurally different shape from `textBlock`'s single title+subtitle.
