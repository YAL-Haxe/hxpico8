### What's this
This is an experimental Haxe compiler target for pico-8.

It's primary purpose is generating laconic Lua code that can be compared to handwritten code while still retaining support for most Haxe' features.

It can also be viewed as an example of how [JS Generator API](http://api.haxe.org/haxe/macro/JSGenApi.html) can be used to quickly prototype new language targets.

### What's pico-8
[Pico-8](http://www.lexaloffle.com/pico-8.php) is a "fantasy console". It has a number of strict restrictions and is interesting to experiment with.

It also has it's own flavour of [Lua](http://lua.org) scriptting language, which gets us here.

If you have bought the "Humble Mozilla Bundle" some time ago, you should already own it together with Voxatron.

### How to use this
1. Setup this repository as a haxelib (see `haxelib git`)
2. [Download](http://builds.haxe.org/) and install Haxe 3.2.
3. Setup your project to use the library. This is done by adding the following into your HXML file (or Project Properties - Compiler Options - Additional Compiler Options in FlashDevelop):
```
-lib hxpico8
--macro p8gen.PgMain.use()
-dce full
```
The project should be pointed generate either a .lua file, or to a .p8xm (which will update a .p8 of the same name with new code section).

You'll most likely want to use the `Pico` class, which maps the built-in functions of the console. Since Pico-8 does not include the standard Lua function set, very little of standard Haxe API is supported.

For additional examples, see the [hxpico8 example repository](https://github.com/YellowAfterlife/hxpico8xm).
