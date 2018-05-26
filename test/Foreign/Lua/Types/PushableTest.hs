{-
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
{-# LANGUAGE OverloadedStrings #-}
{-|
Module      :  Foreign.Lua.Types.PushableTest
Copyright   :  © 2017-2018 Albert Krewinkel
License     :  MIT

Maintainer  :  Albert Krewinkel <tarleb+hslua@zeitkraut.de>
Stability   :  stable
Portability :  portable

Test for the interoperability between haskell and lua.
-}
module Foreign.Lua.Types.PushableTest (tests) where

import Data.ByteString (ByteString)
import Data.Monoid ((<>))
import Foreign.Lua
import Foreign.StablePtr (castStablePtrToPtr, freeStablePtr, newStablePtr)

import Test.HsLua.Arbitrary ()
import Test.QuickCheck (Property)
import Test.QuickCheck.Instances ()
import Test.QuickCheck.Monadic (monadicIO, run, assert)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (Assertion, assertBool, testCase)
import Test.Tasty.QuickCheck (testProperty)

-- | Specifications for Attributes parsing functions.
tests :: TestTree
tests = testGroup "Pushable"
  [ testGroup "pushing simple values to the stack"
    [ testCase "Boolean can be pushed correctly" $
      assertLuaEqual "true was not pushed"
        True
        "true"

    , testCase "LuaNumbers can be pushed correctly" $
      assertLuaEqual "5::LuaNumber was not pushed"
        (5 :: LuaNumber)
        "5"

    , testCase "LuaIntegers can be pushed correctly" $
      assertLuaEqual "42::LuaInteger was not pushed"
        (42 :: LuaInteger)
        "42"

    , testCase "ByteStrings can be pushed correctly" $
      assertLuaEqual "string literal was not pushed"
        ("Hello!" :: ByteString)
        "\"Hello!\""

    , testCase "Unit is pushed as nil" $
      assertLuaEqual "() was not pushed as nil"
        ()
        "nil"

    , testCase "Pointer is pushed as light userdata" $
      let luaOp = do
            stblPtr <- liftIO $ newStablePtr (Just "5" :: Maybe String)
            push (castStablePtrToPtr stblPtr)
            res <- islightuserdata (-1)
            liftIO $ freeStablePtr (stblPtr)
            return res
      in assertBool "pointers must become light userdata" =<< runLua luaOp
    ]

  , testGroup "pushing a value increases stack size by one"
    [ testProperty "LuaInteger"
      (prop_pushIncrStackSizeByOne :: LuaInteger -> Property)
    , testProperty "LuaNumber"
      (prop_pushIncrStackSizeByOne :: LuaNumber -> Property)
    , testProperty "ByteString"
      (prop_pushIncrStackSizeByOne :: ByteString -> Property)
    , testProperty "String"
      (prop_pushIncrStackSizeByOne :: String -> Property)
    , testProperty "list of booleans"
      (prop_pushIncrStackSizeByOne :: [Bool] -> Property)
    ]
  ]

-- | Takes a message, haskell value, and a representation of that value as lua
-- string, assuming that the pushed values are equal within lua.
assertLuaEqual :: Pushable a => String -> a -> String -> Assertion
assertLuaEqual msg x lit = assertBool msg =<< runLua
  (loadstring ("return " <> lit) *> call 0 1
   *> push x
   *> equal (-1) (-2))

prop_pushIncrStackSizeByOne :: Pushable a => a -> Property
prop_pushIncrStackSizeByOne x = monadicIO $ do
  (oldSize, newSize) <- run $ runLua ((,) <$> gettop <*> (push x *> gettop))
  assert (newSize == succ oldSize)
