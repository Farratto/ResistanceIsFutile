## Resistance is Futile

**Current Version**: ~v-dev~ \
**Updated**: ~date~

This extension adds effects for extra functionality around damage resistance and immunity.

### Installation

Recommend disable and hide Blissful Ignornance from Fantasy Grounds Forge and delete BlissfulIgnorance.ext from your extensions folder. \
You can find the source code at Farratto's [GitHub](https://github.com/Farratto/ResistanceIsFutile). \
You can ask questions at the [Fantasy Grounds Forum](https://www.fantasygrounds.com/forums/showthread.php?84384-5E-Resistance-is-Futile).

### Details

The following targetable Effects have been added:
* **ABSORB: (n), types** - When the target takes damage from one of the provided damage types, they instead are healed for n times the damage. n is optional and defaults to 1. e.g. "ABSORB: lightning" may be used for a shambling mound.
* **IGNORE[R]: types** - Damage dealt by the bearer of this effect will ignore R to any of the damage types, where R can be one of ABSORB, IMMUNE, RESIST, or VULN. e.g. "IGNORERESIST: fire" for a Fire Elemental Adept.
* **[R1]TO[R2]: types** - Damage dealt by the bearer of this effect will treat R1 as R2 for any of the damage types, where R1 and R2 may be one of ABSORB, IMMUNE, RESIST, or VULN. e.g. "IMMUNETORESIST: radiant" would cause the damage dealt by a paladin's divine smite to treat radiant immunity as radiant resistance instead.
* **MAKEVULN: types** - Damage dealt by the bearer of this effect will treat a creature without any sort of resistance to the damage types as if they were vulnerable. e.g. "MAKEVULN: slashing" would cause a wraith to take double damage from magic swords, but still take half damage from nonmagical, unsilvered swords.
* **MAKERESIST: types** - Functions the same as MAKEVULN.
* **REDUCE: n, types** - This functions exactly as RESIST: n, except it will also stack with normal resistance.
* **UNHEALABLE: (types)** - The bearer of this effect cannot benefit from any healing of the associated types. types is optional and may be any combination of "heal", "hitdice", and "rest", separated by commas. If types is not provided, then all types of healing are prevented.
* **DMGMULT: n** - The bearer of this effect has all of their damage dealt multiplied by n. If n is negative, damage will heal instead.
* **DMGEDMULT: n** - The bearer of this effect has all of their damage taken multiplied by n. If n is negative, damage will heal instead.
* **HEALMULT: n (types)** - The bearer of this effect has all of their healing done multiplied by n. If n is negative, healing will damage instead. In this case, you may optionally specify damage types separated by a comma.
* **HEALEDMULT: n, (types)** - The bearer of this effect has all of their healing received multiplied by n. types is optional and may be any combination of "heal", "hitdice", and "rest", separated by commas. If types is not provided, then all types of healing are multiplied. If n is negative, healing will damage instead. In this case, you may optionally specify damage types separated by a comma.

### Attribution

Resistance is Futile is a rebranding of MeAndUnique's Blissful Ignorance, now maintained by Farratto under the MIT license. \
Icon made by [Delapouite](https://delapouite.com/) from [Game-icons.net](https://game-icons.net/1x1/delapouite/electrical-resistance.html). \
SmiteWorks owns rights to code sections copied from their rulesets by permission for Fantasy Grounds community development. \
'Fantasy Grounds' is a trademark of SmiteWorks USA, LLC. \
'Fantasy Grounds' is Copyright 2004-2021 SmiteWorks USA LLC.

### Change Log

* v1.1.9: FIXED: 5E ruleset update on 2025-09-02 introduced error triggered by damage rolls.
* v1.1.8: removed DMGTYPENEW rendered obsolete by DMGBASETYPE
* v1.1.7: Rebranding to Resistance is Futile.
* v1.1.6-rc6: Console log spamming. FIXED.
* v1.1.6-rc5: Support for negative n on DMGMULT DMGEDMULT HEALMULT HEALEDMULT
* v1.1.6-rc4: Increased compatibility with other Extensions.
* v1.1.6-rc3: Rare Bug Error Protection. Compressed icon.
* v1.1.6-rc2: New tag: DMGTYPENEW replaces damage types.
* v1.1.6-rc1: new modifier tag: MAKERESIST