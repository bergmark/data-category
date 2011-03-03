{-# LANGUAGE TypeOperators, TypeFamilies #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Category.Yoneda
-- Copyright   :  (c) Sjoerd Visscher 2010
-- License     :  BSD-style (see the file LICENSE)
--
-- Maintainer  :  sjoerd@w3future.com
-- Stability   :  experimental
-- Portability :  non-portable
-----------------------------------------------------------------------------
module Data.Category.Yoneda where

import Prelude (($))

import Data.Category
import Data.Category.Functor
import Data.Category.NaturalTransformation
import Data.Category.CartesianClosed

-- The Yoneda emedding is just the Hom functor in curried form:
-- curry (CatA Id) (CatA Id) (CatA Id) (CatA Hom)
-- leftAdjunct (curryAdj (CatA Id)) (CatA Id) (CatA Hom)
-- (ExponentialWith (CatA Id) % (CatA Hom)) . (tuple (CatA Id) (CatA Id))
-- CatA (Wrap Hom Id) . CatA CatTuple
-- CatA (Postcompose Hom :.: CatTuple)

-- | The Yoneda embedding functor.
yonedaEmbedding :: Category (~>) => Postcompose (Hom (~>)) (~>) :.: CatTuple (~>) (Op (~>))
yonedaEmbedding = Postcompose Hom :.: CatTuple


data Yoneda f = Yoneda
type instance Dom (Yoneda f) = Dom f
type instance Cod (Yoneda f) = (->)
type instance Yoneda f :% a = Nat (Dom f) (->) (a :*-: Dom f) f
instance Functor f => Functor (Yoneda f) where
  Yoneda % ab = \n -> n . yonedaEmbedding % Op ab
      
  
fromYoneda :: (Functor f, Cod f ~ (->)) => f -> Yoneda f :~> f
fromYoneda f = Nat Yoneda f $ \a n -> (n ! a) a

toYoneda :: (Functor f, Cod f ~ (->)) => f -> f :~> Yoneda f
toYoneda f = Nat f Yoneda $ \a fa -> Nat (homX_ a) f $ \_ h -> (f % h) fa

-- Contravariant Yoneda:
-- type instance Yoneda f :% a = Nat (Op (Dom f)) (->) (Dom f :-*: a) f
