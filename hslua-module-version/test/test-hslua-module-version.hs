{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}
{-|
Module      : Main
Copyright   : © 2021 Albert Krewinkel
License     : MIT
Maintainer  : Albert Krewinkel <albert+hslua@zeitkraut.de>

Tests for the `version` Lua module.
-}
module Main (main) where

import Control.Monad (void)
import HsLua (Lua)
import HsLua.Packaging.Module (preloadModule, preloadModuleWithName, pushModule)
import HsLua.Module.Version (documentedModule)
import Test.Tasty (TestTree, defaultMain, testGroup)
import Test.Tasty.HUnit (assertEqual, testCase)
import Test.Tasty.Lua (translateResultsFromFile)

import qualified HsLua as Lua

main :: IO ()
main = do
  luaTestResults <- Lua.run @Lua.Exception $ do
    Lua.openlibs
    Lua.registerModule documentedModule
    Lua.pop 1
    translateResultsFromFile "test/test-version.lua"
  defaultMain $ testGroup "hslua-module-version" [tests, luaTestResults]

-- | HSpec tests for the Lua 'version' module
tests :: TestTree
tests = testGroup "HsLua version module"
  [ testCase "version module can be pushed to the stack" $
      Lua.run (void (pushModule documentedModule) :: Lua ())

  , testCase "version module can be added to the preloader" . Lua.run $ do
      Lua.openlibs
      preloadModule documentedModule
      assertEqual' "function not added to preloader" Lua.TypeFunction =<< do
        Lua.getglobal' "package.preload.Version"
        Lua.ltype (-1)

  , testCase "version module can be loaded as hsversion" . Lua.run $ do
      Lua.openlibs
      preloadModuleWithName documentedModule "hsversion"
      assertEqual' "loading the module fails " Lua.OK =<<
        Lua.dostring "require 'hsversion'"
  ]

assertEqual' :: (Show a, Eq a) => String -> a -> a -> Lua ()
assertEqual' msg expected = Lua.liftIO . assertEqual msg expected
