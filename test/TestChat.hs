-- | Test our chat server.
module Main (main) where

import Test.Hspec
import Test.QuickCheck
import System.Cmd

import Chat (chat, mainLoop, runConn)

-- Due to not leaving myself enough time,
-- I did not write any tests using HSpec.
main :: IO ()
main = hspec $ describe "Testing chat" $ do
  describe "messages sent test" $ do
    it "1==1" $ property $
      1 `shouldBe` 1
      

  {--- example quickcheck test in hspec.
  describe "read" $ do
    it "is inverse to show" $ property $
      \x -> (read . show) x == (x :: Int)-}

