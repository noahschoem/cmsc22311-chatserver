-- | CS240h Lab 2 Chat Server
{- This code is taken heavily from the Haskell Wiki's guide 
   on how to build a chat server
   (https://wiki.haskell.org/Implement_a_chat_server)
   and rewritten and modified to fit the requirements of the project. -}
module Chat (chat) where
import Network    (Socket, PortID (PortNumber), 
                    withSocketsDo, listenOn, accept)
import System.IO  (BufferMode (NoBuffering), Handle,
                   hSetBuffering, hPutStrLn, hGetLine, hClose)
import Control.Concurrent (forkIO, killThread)
import Control.Concurrent.Chan
import Control.Monad     (when)
import Control.Monad.Fix (fix)
import Control.Exception (SomeException (..), handle)

type Message = (String,Int) -- (message body,user id)

-- | Chat server entry point.
chat :: Int -> IO ()
chat port = withSocketsDo $ do
  sock <- listenOn $ PortNumber $ fromIntegral port
  chan <- newChan
  mainLoop sock chan 1
  
mainLoop :: Socket -> Chan Message -> Int -> IO ()
mainLoop sock chan n = do   
  (hdl,_,_) <- accept sock
  hSetBuffering hdl NoBuffering
  _ <- forkIO (runConn hdl chan n)
  mainLoop sock chan (n+1)

runConn :: Handle -> Chan Message -> Int -> IO ()
runConn hdl chan n = do
  chan' <- dupChan chan
  {- since users only ever get assigned positive integer id's, 
     messages with an user id of 0 get seen by everyone.
     We'll use user id of 0 to represent server-wide messages. -}
  writeChan chan ("Welcome " ++ show n ++ " to the server!",0)
  thread <- forkIO $ fix $ \loop -> do
    (line,user) <- readChan chan'
    when (user /= n) $ hPutStrLn hdl line
    loop
  handle (\(SomeException _) -> return ()) $ fix $ \loop -> do
    line <- hGetLine hdl
    writeChan chan' (show n ++ ": " ++ line,n)
    loop
  hClose hdl
  killThread thread
  writeChan chan (show n ++ " has left.",0)