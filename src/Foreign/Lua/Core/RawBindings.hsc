{-
Copyright © 2007-2012 Gracjan Polak
Copyright © 2012-2016 Ömer Sinan Ağacan
Copyright © 2017-2018 Albert Krewinkel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-}
{-|
Module      : Foreign.Lua.Core.RawBindings
Copyright   : © 2007–2012 Gracjan Polak,
                2012–2016 Ömer Sinan Ağacan,
                2017-2018 Albert Krewinkel
License     : MIT
Maintainer  : Albert Krewinkel <tarleb+hslua@zeitkraut.de>
Stability   : beta
Portability : ForeignFunctionInterface

Haskell bindings to lua C API functions.
-}
module Foreign.Lua.Core.RawBindings where

import Foreign.C
import Foreign.Lua.Core.Types
import Foreign.Ptr

#include "safer-api.h"

##ifdef ALLOW_UNSAFE_GC
##define SAFTY unsafe
##else
##define SAFTY safe
##endif

-- TODO: lua_getallocf, lua_setallocf
-- TODO: Debugger functions

-- Some of the Lua functions may call a Haskell function, and trigger
-- garbage collection, rescheduling etc. This means we must declare these
-- functions as 'safe'.


--------------------------------------------------------------------------------
-- * State manipulation

-- lua_newstate is currently not supported.

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_close lua_close>
foreign import ccall "lua.h lua_close"
  lua_close :: LuaState -> IO ()

-- lua_newthread is currently not supported.


--------------------------------------------------------------------------------
-- * Basic stack manipulation

#if LUA_VERSION_NUMBER >= 502
-- | See <https://www.lua.org/manual/5.3/manual.html#lua_absindex lua_absindex>
foreign import ccall unsafe "lua.h lua_absindex"
  lua_absindex :: LuaState -> StackIndex -> IO StackIndex
#endif

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_gettop lua_gettop>
foreign import ccall unsafe "lua.h lua_gettop"
  lua_gettop :: LuaState -> IO StackIndex

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_settop lua_settop>
foreign import ccall SAFTY "lua.h lua_settop"
  lua_settop :: LuaState -> StackIndex -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_pushvalue lua_pushvalue>
foreign import ccall SAFTY "lua.h lua_pushvalue"
  lua_pushvalue :: LuaState -> StackIndex -> IO ()

#if LUA_VERSION_NUMBER >= 503
-- | See <https://www.lua.org/manual/5.3/manual.html#lua_copy lua_copy>
foreign import ccall SAFTY "lua.h lua_copy"
  lua_copy :: LuaState -> StackIndex -> StackIndex -> IO ()
#endif

-- | See <https://www.lua.org/manual/5.2/manual.html#lua_remove lua_remove>
foreign import capi SAFTY "lua.h lua_remove"
  lua_remove :: LuaState -> StackIndex -> IO ()

-- | See <https://www.lua.org/manual/5.2/manual.html#lua_insert lua_insert>
foreign import capi SAFTY "lua.h lua_insert"
  lua_insert :: LuaState -> StackIndex -> IO ()

-- | See <https://www.lua.org/manual/5.2/manual.html#lua_replace lua_replace>
foreign import capi SAFTY "lua.h lua_replace"
  lua_replace :: LuaState -> StackIndex -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_checkstack lua_checkstack>
foreign import capi SAFTY "lua.h lua_checkstack"
  lua_checkstack :: LuaState -> StackIndex -> IO LuaBool

-- lua_xmove is currently not supported.


--------------------------------------------------------------------------------
-- * Stack access functions

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_isnumber lua_isnumber>
foreign import ccall SAFTY "lua.h lua_isnumber"
  lua_isnumber :: LuaState -> StackIndex -> IO LuaBool

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_isstring lua_isstring>
foreign import ccall SAFTY "lua.h lua_isstring"
  lua_isstring :: LuaState -> StackIndex -> IO LuaBool

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_iscfunction lua_iscfunction>
foreign import ccall SAFTY "lua.h lua_iscfunction"
  lua_iscfunction :: LuaState -> StackIndex -> IO LuaBool

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_isuserdata lua_isuserdata>
foreign import ccall SAFTY "lua.h lua_isuserdata"
  lua_isuserdata :: LuaState -> StackIndex -> IO LuaBool

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_type lua_type>
foreign import ccall SAFTY "lua.h lua_type"
  lua_type :: LuaState -> StackIndex -> IO TypeCode

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_typename lua_typename>
foreign import ccall SAFTY "lua.h lua_typename"
  lua_typename :: LuaState -> TypeCode -> IO CString

-- lua_compare is unsafe (might cause a longjmp), use hslua_compare instead.
#if LUA_VERSION_NUM >= 502
-- | Wrapper around <https://lua.org/manual/5.3/manual.html#lua_compare \
-- @lua_compare@> which catches any @longjmp@s.
foreign import ccall "safer-api.h hslua_compare"
  hslua_compare :: LuaState -> StackIndex -> StackIndex -> CInt
                -> IO (Failable LuaBool)
#else
-- | See <https://www.lua.org/manual/5.1/manual.html#lua_equal lua_equal>
foreign import ccall "lua.h lua_equal"
  lua_equal :: LuaState -> StackIndex -> StackIndex -> IO LuaBool

-- | See <https://www.lua.org/manual/5.1/manual.html#lua_lessthan lua_lessthan>
foreign import ccall "lua.h lua_lessthan"
  lua_lessthan :: LuaState -> StackIndex -> StackIndex -> IO LuaBool
#endif

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_rawequal lua_rawequal>
foreign import ccall SAFTY "lua.h lua_rawequal"
  lua_rawequal :: LuaState -> StackIndex -> StackIndex -> IO LuaBool

--
-- Type coercion
--
-- | See <https://www.lua.org/manual/5.3/manual.html#lua_toboolean lua_toboolean>
foreign import capi SAFTY "lua.h lua_toboolean"
  lua_toboolean :: LuaState -> StackIndex -> IO LuaBool

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_tocfunction lua_tocfunction>
foreign import ccall SAFTY "lua.h lua_tocfunction"
  lua_tocfunction :: LuaState -> StackIndex -> IO CFunction

#if LUA_VERSION_NUMBER >= 502
-- | See <https://www.lua.org/manual/5.3/manual.html#lua_tointegerx lua_tointegerx>
foreign import ccall SAFTY "lua.h lua_tointegerx"
  lua_tointegerx :: LuaState -> StackIndex -> Ptr LuaBool -> IO LuaInteger

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_tonumberx lua_tonumberx>
foreign import ccall SAFTY "lua.h lua_tonumberx"
  lua_tonumberx :: LuaState -> StackIndex -> Ptr LuaBool -> IO LuaNumber
#endif

-- | See <https://www.lua.org/manual/5.1/manual.html#lua_tointeger lua_tointeger>
foreign import capi SAFTY "lua.h lua_tointeger"
  lua_tointeger :: LuaState -> StackIndex -> IO LuaInteger

-- | See <https://www.lua.org/manual/5.1/manual.html#lua_tonumber lua_tonumber>
foreign import capi SAFTY "lua.h lua_tonumber"
  lua_tonumber :: LuaState -> StackIndex -> IO LuaNumber

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_tolstring lua_tolstring>
foreign import ccall SAFTY "lua.h lua_tolstring"
  lua_tolstring :: LuaState -> StackIndex -> Ptr CSize -> IO (Ptr CChar)

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_topointer lua_topointer>
foreign import ccall SAFTY "lua.h lua_topointer"
  lua_topointer :: LuaState -> StackIndex -> IO (Ptr ())

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_tothread lua_tothread>
foreign import ccall SAFTY "lua.h lua_tothread"
  lua_tothread :: LuaState -> StackIndex -> IO LuaState

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_touserdata lua_touserdata>
foreign import ccall SAFTY "lua.h lua_touserdata"
  lua_touserdata :: LuaState -> StackIndex -> IO (Ptr a)


--
-- Object size
--

#if LUA_VERSION_NUMBER >= 502
-- | See <https://www.lua.org/manual/5.3/manual.html#lua_rawlen lua_rawlen>
foreign import ccall SAFTY "lua.h lua_rawlen"
  lua_rawlen :: LuaState -> StackIndex -> IO CSize
#else
-- | See <https://www.lua.org/manual/5.1/manual.html#lua_objlen lua_objlen>
foreign import ccall SAFTY "lua.h lua_objlen"
  lua_objlen :: LuaState -> StackIndex -> IO CSize
#endif


--------------------------------------------------------------------------------
-- * Push functions

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_pushnil lua_pushnil>
foreign import ccall SAFTY "lua.h lua_pushnil"
  lua_pushnil :: LuaState -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_pushnumber lua_pushnumber>
foreign import ccall SAFTY "lua.h lua_pushnumber"
  lua_pushnumber :: LuaState -> LuaNumber -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_pushinteger lua_pushinteger>
foreign import ccall SAFTY "lua.h lua_pushinteger"
  lua_pushinteger :: LuaState -> LuaInteger -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_pushlstring lua_pushlstring>
foreign import ccall SAFTY "lua.h lua_pushlstring"
  lua_pushlstring :: LuaState -> Ptr CChar -> CSize -> IO ()

-- lua_pushstring is currently not supported. It's difficult to use in a haskell
-- context.

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_pushcclosure lua_pushcclosure>
foreign import ccall SAFTY "lua.h lua_pushcclosure"
  lua_pushcclosure :: LuaState -> CFunction -> NumArgs -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_pushboolean lua_pushboolean>
foreign import ccall SAFTY "lua.h lua_pushboolean"
  lua_pushboolean :: LuaState -> LuaBool -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_pushlightuserdata lua_pushlightuserdata>
foreign import ccall SAFTY "lua.h lua_pushlightuserdata"
  lua_pushlightuserdata :: LuaState -> Ptr a -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_pushthread lua_pushthread>
foreign import ccall SAFTY "lua.h lua_pushthread"
  lua_pushthread :: LuaState -> IO CInt


--------------------------------------------------------------------------------
-- * Get functions

-- lua_gettable is unsafe, use hslua_gettable instead.
-- lua_getfield is unsafe, use hslua_getfield instead.
-- lua_getglobal is unsafe, use hslua_getglobal instead.
-- lua_getfenv (5.1 only) is not supported.

-- | Wrapper around <https://lua.org/manual/5.3/manual.html#lua_gettable \
-- @lua_gettable@> which catches any @longjmp@s.
foreign import ccall "safer-api.h hslua_gettable"
  hslua_gettable :: LuaState -> StackIndex -> IO (Failable ())

-- | Wrapper around <https://lua.org/manual/5.3/manual.html#lua_getfield \
-- @lua_getfield@> which catches any @longjmp@s.
foreign import ccall "safer-api.h hslua_getfield"
  hslua_getfield :: LuaState -> StackIndex -> CString -> IO (Failable ())

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_rawget lua_rawget>
foreign import ccall SAFTY "lua.h lua_rawget"
  lua_rawget :: LuaState -> StackIndex -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_rawgeti lua_rawgeti>
foreign import ccall SAFTY "lua.h lua_rawgeti"
  lua_rawgeti :: LuaState -> StackIndex -> LuaInteger -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_createtable lua_createtable>
foreign import ccall SAFTY "lua.h lua_createtable"
  lua_createtable :: LuaState -> CInt -> CInt -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_newuserdata lua_newuserdata>
foreign import ccall SAFTY "lua.h lua_newuserdata"
  lua_newuserdata :: LuaState -> CSize -> IO (Ptr ())

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_getmetatable lua_getmetatable>
foreign import ccall SAFTY "lua.h lua_getmetatable"
  lua_getmetatable :: LuaState -> StackIndex -> IO LuaBool

-- | Wrapper around <https://lua.org/manual/5.3/manual.html#lua_getglobal \
-- @lua_getglobal@> which catches any @longjmp@s.
foreign import ccall "safer-api.h hslua_getglobal"
  hslua_getglobal :: LuaState -> CString -> IO (Failable ())


--------------------------------------------------------------------------------
-- * Set functions

-- lua_settable is unsafe, use hslua_settable instead.
-- lua_setfield is unsafe, use hslua_setfield instead.
-- lua_setglobal is unsafe, use hslua_setglobal instead.
-- lua_setfenv (5.1 only) is not supported.

-- | Wrapper around <https://lua.org/manual/5.3/manual.html#lua_settable \
-- @lua_settable@> which catches any @longjmp@s.
foreign import ccall "safer-api.h hslua_settable"
  hslua_settable :: LuaState -> StackIndex -> IO (Failable ())

-- | Wrapper around <https://lua.org/manual/5.3/manual.html#lua_setfield \
-- @lua_setfield@> which catches any @longjmp@s.
foreign import ccall "safer-api.h hslua_setfield"
  hslua_setfield :: LuaState -> StackIndex -> CString -> IO (Failable ())

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_rawset lua_rawset>
foreign import ccall SAFTY "lua.h lua_rawset"
  lua_rawset :: LuaState -> StackIndex -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_rawseti lua_rawseti>
foreign import ccall SAFTY "lua.h lua_rawseti"
  lua_rawseti :: LuaState -> StackIndex -> LuaInteger -> IO ()

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_setmetatable lua_setmetatable>
foreign import ccall SAFTY "lua.h lua_setmetatable"
  lua_setmetatable :: LuaState -> StackIndex -> IO ()

-- | Wrapper around <https://lua.org/manual/5.3/manual.html#lua_setglobal \
-- @lua_setglobal@> which catches any @longjmp@s.
foreign import ccall "safer-api.h hslua_setglobal"
  hslua_setglobal :: LuaState -> CString -> IO (Failable ())


--------------------------------------------------------------------------------
-- * 'load' and 'call' functions (load and run Lua code)

-- lua_call is inherently unsafe, we do not support it.

-- | See <https://www.lua.org/manual/5.1/manual.html#lua_pcall lua_pcall>
foreign import capi "lua.h lua_pcall"
  lua_pcall :: LuaState -> NumArgs -> NumResults -> StackIndex
            -> IO StatusCode

#if LUA_VERSION_NUMBER >= 502
-- | See <https://www.lua.org/manual/5.3/manual.html#lua_load lua_load>
foreign import ccall safe "lua.h lua_load"
  lua_load :: LuaState -> LuaReader -> Ptr () -> CString -> CString
           -> IO StatusCode
#else
-- | See <https://www.lua.org/manual/5.1/manual.html#lua_load lua_load>
foreign import ccall safe "lua.h lua_load"
  lua_load :: LuaState -> LuaReader -> Ptr () -> CString
           -> IO StatusCode
#endif

-- currently unsupported:
-- lua_dump


------------------------------------------------------------------------------
-- * Coroutine functions

-- lua_yield / lua_yieldk and lua_resume are currently not supported.

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_status lua_status>
foreign import ccall unsafe "lua.h lua_status"
  lua_status :: LuaState -> IO StatusCode


------------------------------------------------------------------------------
-- * Garbage-collection functions and options

-- | See <https://www.lua.org/manual/5.3/manual.html#lua_gc lua_gc>
foreign import ccall "lua.h lua_gc"
  lua_gc :: LuaState -> CInt -> CInt -> IO CInt


------------------------------------------------------------------------------
-- * Miscellaneous functions

-- lua_error is unsafe in a haskell context and hence not supported.
-- lua_next is unsafe, use hslua_next instead.
-- lua_concat is unsafe (may trigger a longjmp), use hslua_concat instead.

-- | Wrapper around <https://lua.org/manual/5.3/manual.html#lua_next \
-- @lua_next@> which catches any @longjmp@s.
foreign import ccall "safer-api.h hslua_next"
  hslua_next :: LuaState -> StackIndex -> IO (Failable LuaBool)

-- | Wrapper around <https://lua.org/manual/5.3/manual.html#lua_concat \
-- @lua_concat@> which catches any @longjmp@s.
foreign import ccall "safer-api.h hslua_concat"
  hslua_concat :: LuaState -> NumArgs -> IO (Failable ())


------------------------------------------------------------------------------
-- * Lua Libraries

-- | See <https://www.lua.org/manual/5.3/manual.html#luaL_openlibs luaL_openlibs>
foreign import ccall unsafe "lualib.h luaL_openlibs"
  luaL_openlibs :: LuaState -> IO ()

-- | Point to function opening the base library.
foreign import ccall unsafe "lualib.h &luaopen_base"
  lua_open_base_ptr :: CFunction

-- | Point to function opening the table library.
foreign import ccall unsafe "lualib.h &luaopen_table"
  lua_open_table_ptr :: CFunction

-- | Point to function opening the io library.
foreign import ccall unsafe "lualib.h &luaopen_io"
  lua_open_io_ptr :: CFunction

-- | Point to function opening the os library.
foreign import ccall unsafe "lualib.h &luaopen_os"
  lua_open_os_ptr :: CFunction

-- | Point to function opening the string library.
foreign import ccall unsafe "lualib.h &luaopen_string"
  lua_open_string_ptr :: CFunction

-- | Point to function opening the math library.
foreign import ccall unsafe "lualib.h &luaopen_math"
  lua_open_math_ptr :: CFunction

-- | Point to function opening the debug library.
foreign import ccall unsafe "lualib.h &luaopen_debug"
  lua_open_debug_ptr :: CFunction

-- | Point to function opening the package library.
foreign import ccall unsafe "lualib.h &luaopen_package"
  lua_open_package_ptr :: CFunction


--------------------------------------------------------------------------------
-- * The Auxiliary Library

-- | See <https://www.lua.org/manual/5.3/manual.html#luaL_newstate luaL_newstate>
foreign import ccall unsafe "lauxlib.h luaL_newstate"
  luaL_newstate :: IO LuaState

-- | See <https://www.lua.org/manual/5.3/manual.html#luaL_newmetatable luaL_newmetatable>
foreign import ccall "lauxlib.h luaL_newmetatable"
  luaL_newmetatable :: LuaState -> CString -> IO LuaBool

-- | See <https://www.lua.org/manual/5.3/manual.html#luaL_ref luaL_ref>
foreign import ccall "lauxlib.h luaL_ref"
  luaL_ref :: LuaState -> StackIndex -> IO CInt

-- | See <https://www.lua.org/manual/5.3/manual.html#luaL_unref luaL_unref>
foreign import ccall "lauxlib.h luaL_unref"
  luaL_unref :: LuaState -> StackIndex -> CInt -> IO ()

-- | See <https://www.lua.org/manual/5.1/manual.html#luaL_loadfile luaL_loadfile>
foreign import capi "lauxlib.h luaL_loadfile"
  luaL_loadfile :: LuaState -> CString -> IO StatusCode

-- | See <https://www.lua.org/manual/5.1/manual.html#luaL_loadstring luaL_loadbuffer>
foreign import capi SAFTY "lauxlib.h luaL_loadbuffer"
  luaL_loadbuffer :: LuaState -> Ptr CChar -> CSize -> CString -> IO StatusCode

--------------------------------------------------------------------------------
-- * Error transformation (Haskell to Lua)
foreign import ccall "safer-api.h &hslua_call_hs"
  hslua_call_hs_ptr :: CFunction
