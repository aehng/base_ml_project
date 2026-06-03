from abc import ABC, abstractmethod
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.base import BaseEstimator
from sklearn.metrics import classification_report, mean_absolute_error, mean_squared_error, r2_score, root_mean_squared_error
import polars as pl
import pandas as pd
import numpy as np

"""
-----------------------------------------------------------------------------------------
Abstract Transformation Class. Please Inherit from this class for any new transformations
-----------------------------------------------------------------------------------------
"""
class Transformation(ABC):

    @abstractmethod
    def fit(self, df: pl.DataFrame):
        return self
    
    @abstractmethod
    def transform(self, df: pl.DataFrame) -> pl.DataFrame:
        pass

    def fit_transform(self, df: pl.DataFrame) -> pl.DataFrame:
        return self.fit(df).transform(df)
    
"""
--------------------------------------------------------------------------------------
Please Code any new Transformation Child Classes directly below this comment.  
--------------------------------------------------------------------------------------
"""

class HourOfDaySine(Transformation):
    def __init__(self, hour_col: str = "hour", output_col: str = "hour_sin"):
        self.hour_col = hour_col
        self.output_col = output_col

    def fit(self, df: pl.DataFrame):
        return self

    def transform(self, df: pl.DataFrame) -> pl.DataFrame:
        return df.with_columns(
            (
                pl.col(self.hour_col)
                .cast(pl.Float64)
                .mul(2.0 * np.pi / 24.0)
                .sin()
                .alias(self.output_col)
            )
        )
