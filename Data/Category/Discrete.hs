{-# LANGUAGE TypeFamilies, TypeOperators, GADTs, RankNTypes, ScopedTypeVariables, FlexibleContexts, FlexibleInstances, UndecidableInstances, NoImplicitPrelude #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Category.Discrete
-- License     :  BSD-style (see the file LICENSE)
--
-- Maintainer  :  sjoerd@w3future.com
-- Stability   :  experimental
-- Portability :  non-portable
--
-- Discrete n, the category with n objects, and as the only arrows their identities.
-----------------------------------------------------------------------------
module Data.Category.Discrete (

  -- * Discrete Categories
    Discrete(..)
  , Z, S
  , Void
  , Unit
  , Pair
  , magicZ
  
  -- * Functors
  , Succ(..)
  , DiscreteDiagram(..)
    
  -- * Natural Transformations
  , voidNat
    
) where

import Data.Category
import Data.Category.Functor
import Data.Category.NaturalTransformation


data Z
data S n

-- | The arrows in Discrete n, a finite set of identity arrows.
data Discrete :: * -> * -> * -> * where
  Z :: Discrete (S n) Z Z
  S :: Discrete n a a -> Discrete (S n) (S a) (S a)


magicZ :: Discrete Z a b -> x
magicZ x = magicZ x


-- | @Discrete Z@ is the discrete category with no objects.
instance Category (Discrete Z) where
  
  src = magicZ
  tgt = magicZ
  
  (.) = magicZ


-- | @Discrete (S n)@ is the discrete category with one object more than @Discrete n@.
instance Category (Discrete n) => Category (Discrete (S n)) where
  
  src Z     = Z
  src (S a) = S (src a)
  
  tgt Z     = Z
  tgt (S a) = S (tgt a)
  
  Z   . Z   = Z
  S a . S b = S (a . b)


-- | 'Void' is the empty category.
type Void = Discrete Z
-- | 'Unit' is the discrete category with one object.
type Unit = Discrete (S Z)
-- | 'Pair' is the discrete category with two objects.
type Pair = Discrete (S (S Z))


data Succ n = Succ
type instance Dom (Succ n) = Discrete n
type instance Cod (Succ n) = Discrete (S n)
type instance Succ n :% a = S a
-- | 'Succ' maps each object in @Discrete n@ to its successor in @Discrete (S n)@.
instance (Category (Discrete n)) => Functor (Succ n) where
  Succ % Z     = S Z
  Succ % (S a) = S (S a)


infixr 7 :::

-- | The functor from @Discrete n@ to @k@, a diagram of @n@ objects in @k@. 
data DiscreteDiagram :: (* -> * -> *) -> * -> * -> * where
  Nil   :: DiscreteDiagram k Z ()
  (:::) :: (Category k, Category (Discrete n)) 
        => Obj k x -> DiscreteDiagram k n xs -> DiscreteDiagram k (S n) (x, xs)
  
type instance Dom (DiscreteDiagram k n xs) = Discrete n
type instance Cod (DiscreteDiagram k n xs) = k
type instance DiscreteDiagram k (S n) (x, xs) :% Z = x
type instance DiscreteDiagram k (S n) (x, xs) :% (S a) = DiscreteDiagram k n xs :% a

-- | The empty diagram.
instance Category k => Functor (DiscreteDiagram k Z ()) where
  Nil        % f = magicZ f

-- | A diagram with one more object.
instance Functor (DiscreteDiagram k n xs) => Functor (DiscreteDiagram k (S n) (x, xs)) where
  (x ::: _)  % Z   = x
  (_ ::: xs) % S n = xs % n


-- | Natural transformations in 'Void' are trivial.
voidNat :: (Functor f, Functor g, Category d, Dom f ~ Void, Dom g ~ Void, Cod f ~ d, Cod g ~ d)
  => f -> g -> Nat Void d f g
voidNat f g = Nat f g magicZ