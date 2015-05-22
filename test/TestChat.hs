-- | Test our chat server.
module Main (main) where

import Test.Hspec
import Test.QuickCheck
import System.Cmd

import Chat

main :: IO ()
main = hspec $ describe "Testing Lab 2" $ do
  describe "dummy test" $ do
    it "1==1" $ property $
      1 `shouldBe` 1
      

  {--- example quickcheck test in hspec.
  describe "read" $ do
    it "is inverse to show" $ property $
      \x -> (read . show) x == (x :: Int)-}

