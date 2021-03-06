{-# LANGUAGE TypeOperators, TypeFamilies, GADTs, FlexibleInstances, NoImplicitPrelude #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Category.Omega
-- License     :  BSD-style (see the file LICENSE)
--
-- Maintainer  :  sjoerd@w3future.com
-- Stability   :  experimental
-- Portability :  non-portable
--
-- Omega, the category 0 -> 1 -> 2 -> 3 -> ... 
-- The objects are the natural numbers, and there's an arrow from a to b iff a <= b.
-----------------------------------------------------------------------------
module Data.Category.Omega where

import Data.Category
import Data.Category.Limit
import Data.Category.Monoidal


data Z
data S n

-- | The arrows of omega, there's an arrow from a to b iff a <= b.
data Omega :: * -> * -> * where
  Z   :: Omega Z Z
  Z2S :: Omega Z n -> Omega Z (S n)
  S   :: Omega a b -> Omega (S a) (S b)
  
-- | The objects of omega are the natural numbers, and there's an arrow from a to b iff a <= b.
instance Category Omega where
  
  src Z       = Z
  src (Z2S _) = Z
  src (S   a) = S (src a)
  
  tgt Z       = Z
  tgt (Z2S a) = S (tgt a)
  tgt (S   a) = S (tgt a)
  
  a     . Z       = a
  (S a) . (Z2S n) = Z2S (a . n)
  (S a) . (S   b) = S   (a . b)


-- | 'Z' (zero) is the initial object of omega.
instance HasInitialObject Omega where
  
  type InitialObject Omega = Z
  
  initialObject    = Z
  
  initialize Z     = Z
  initialize (S n) = Z2S (initialize n)



type instance BinaryProduct Omega Z     n = Z
type instance BinaryProduct Omega n     Z = Z
type instance BinaryProduct Omega (S a) (S b) = S (BinaryProduct Omega a b)

-- | The product in omega is the minimum.
instance HasBinaryProducts Omega where 

  proj1 Z     Z     = Z
  proj1 Z     (S _) = Z
  proj1 (S n) Z     = Z2S (proj1 n Z)
  proj1 (S a) (S b) = S (proj1 a b)

  proj2 Z     Z     = Z
  proj2 Z     (S n) = Z2S (proj2 Z n)
  proj2 (S _) Z     = Z
  proj2 (S a) (S b) = S (proj2 a b)
  
  Z     &&& _     = Z
  _     &&& Z     = Z
  Z2S a &&& Z2S b = Z2S (a &&& b)
  S a   &&& S b   = S (a &&& b)


type instance BinaryCoproduct Omega Z     n     = n
type instance BinaryCoproduct Omega n     Z     = n
type instance BinaryCoproduct Omega (S a) (S b) = S (BinaryCoproduct Omega a b)

-- | The coproduct in omega is the maximum.
instance HasBinaryCoproducts Omega where 
  
  inj1 Z     Z     = Z
  inj1 Z     (S n) = Z2S (inj1 Z n)
  inj1 (S n) Z     = S (inj1 n Z)
  inj1 (S a) (S b) = S (inj1 a b)
  
  inj2 Z     Z     = Z
  inj2 Z     (S n) = S (inj2 Z n)
  inj2 (S n) Z     = Z2S (inj2 n Z)
  inj2 (S a) (S b) = S (inj2 a b)
  
  Z     ||| Z     = Z
  Z2S _ ||| a     = a
  a     ||| Z2S _ = a
  S a   ||| S b   = S (a ||| b)


-- | Zero is a monoid object wrt the maximum.
zeroMonoid :: MonoidObject (CoproductFunctor Omega) Z
zeroMonoid = MonoidObject Z Z

-- | Zero is also a comonoid object wrt the maximum.
zeroComonoid :: ComonoidObject (CoproductFunctor Omega) Z
zeroComonoid = ComonoidObject Z Z