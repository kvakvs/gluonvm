module Bytecode.Func where

import           Bytecode.Op
import           Data.List
import           Term

data BcFunc = BcFunc
  { bcfName :: FunArity
  , bcfCode :: [BcOp]
  }

instance Show BcFunc where
  show (BcFunc (FunArity name arity) body) =
    intercalate "\n" ["", header, ops, footer, ""]
    where
      header = ";; bytecode fun " ++ funarity ++ " ------"
      footer = ";; ------ end bytecode " ++ funarity
      funarity = name ++ "/" ++ show arity
      indent2 t = "  " ++ t
      ops = intercalate "\n" $ map (indent2 . show) body