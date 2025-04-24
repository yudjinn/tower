use bevy::prelude::*;

use crate::components::tower::{DamageType, FiringType, StatChange, Tower};

#[derive(Component)]
pub struct SingleShotTower {
    firing_type: FiringType,
    damage_type: DamageType,
    level: u32,
    purchase_cost: u32,
    stat_changes: Vec<StatChange>,
}

impl Tower for SingleShotTower {
    fn new() -> Self {
        Self {
            firing_type: FiringType::SingleProjectile,
            damage_type: DamageType::Standard,
            level: 1,
            purchase_cost: 100,
            stat_changes: vec![],
        }
    }

    fn stat_changes(&self) -> &Vec<StatChange> {
        &self.stat_changes
    }

    fn cost(&self) -> u32 {
        let base = match self.level {
            1 => 25,
            2 => 50,
            3 => 100,
            4 => 250,
            _ => 9999,
        };
        todo!()
    }

    fn fire_rate(&self) -> f32 {
        let base = match self.level {
            1 => 1.,
            2 => 1.2,
            3 => 1.5,
            4 => 2.,
            _ => 0.,
        };
        todo!()
    }

    fn damage(&self) -> f32 {
        let base = match self.level {
            1 => 1.,
            2 => 3.,
            3 => 5.,
            4 => 7.,
            _ => 0.,
        };
        todo!()
    }

    fn range(&self) -> f32 {
        let base = match self.level {
            1 => 3.,
            2 => 3.5,
            3 => 4.2,
            4 => 5.1,
            _ => 0.,
        };
        todo!()
    }

    fn set_level(&mut self, level: u32) {
        self.level = level;
    }

    fn damage_type(&self) -> &DamageType {
        &self.damage_type
    }

    fn firing_type(&self) -> &FiringType {
        &self.firing_type
    }
}
