-- | CS240h Lab 2 Chat Server
{- This code is taken heavily from the Haskell Wiki's guide 
   on how to build a chat server
   (https://wiki.haskell.org/Implement_a_chat_server)
   and rewritten and modified to fit the requirements of the project. -}
module Chat (chat) where
import Network    (Socket, PortID (PortNumber), 
                    withSocketsDo, listenOn, accept)
import System.IO  (BufferMode (NoBuffering), Handle, utf8,
                   hSetBuffering, hSetEncoding, hPutStrLn, hGetLine, hClose)
import Control.Concurrent (forkIO, killThread)
import Control.Concurrent.Chan
import Control.Monad     (when)
import Control.Monad.Fix (fix)
import Control.Exception (SomeException (..), handle)

type Message = (String,Int) -- (message body,user id)

-- | chat: Chat server entry point.
chat :: Int -> IO ()
chat port = withSocketsDo $ do
  sock <- listenOn $ PortNumber $ fromIntegral port
  chan <- newChan
  mainLoop sock chan 1
  
{- | mainLoop: listens for any new incoming connections
     and spawns a worker thread for handling any new
     connection.  Also keeps track of what username to 
     assign the next connection. -}
mainLoop :: Socket -> Chan Message -> Int -> IO ()
mainLoop sock chan n = do   
  (hdl,_,_) <- accept sock
  hSetBuffering hdl NoBuffering
  hSetEncoding hdl utf8
  _ <- forkIO (runConn hdl chan n)
  mainLoop sock chan (n+1)
  
{- | runConn: runs a connection for user n, inputting from handle
     hdl and reading from channel chan.
     Also manages when a user leaves the channel. -}
runConn :: Handle -> Chan Message -> Int -> IO ()
runConn hdl chan n = do
  chan' <- dupChan chan
  {- since users only ever get assigned positive integer id's, 
     messages with an user id of 0 get seen by everyone.
     We'll use user id of 0 to represent server-wide messages. -}
  writeChan chan (show n ++ " has joined.",0)
  -- forks off a thread for sending user n messages.
  thread <- forkIO $ fix $ \loop -> do
    (line,user) <- readChan chan'
    when (user /= n) $ hPutStrLn hdl line
    loop
  -- reads messages from user n.  Any connection error
  -- (e.g. user closing connection) breaks us out of this
  -- and moves us to the cleanup stage.
  handle (\(SomeException _) -> return ()) $ fix $ \loop -> do
    line <- hGetLine hdl
    writeChan chan' (show n ++ ": " ++ line,n)
    loop
  -- cleaning up after a user leaves
  hClose hdl
  killThread thread
  writeChan chan (show n ++ " has left.",0)