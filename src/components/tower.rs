use bevy::prelude::*;

#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum DamageType {
    Standard,
    Corrosion,
    Fire,
    Frost,
    Spark,
    Aura,
}

#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum FiringType {
    SingleProjectile,
    BurstProjectile,
    Spread,
    Beam,
    Nova,
    Chain,
    Aura, // similar to nova, but a different logical check
}

#[derive(Clone, Copy, PartialEq, PartialOrd)]
pub enum StatChange {
    DamageChange { percent: f32 },
    FireRateChange { percent: f32 },
    RangeChange { percent: f32 },
    CostChange { percent: f32 },
}

impl StatChange {
    pub fn with_stat_change(&self, base: f32) -> f32 {
        match self {
            StatChange::DamageChange { percent } => base * (1. + (percent / 100.)),
            StatChange::FireRateChange { percent } => base * (1. + (percent / 100.)),
            StatChange::RangeChange { percent } => base * (1. + (percent / 100.)),
            StatChange::CostChange { percent } => base * (1. + (percent / 100.)),
        }
    }
}

#[derive(Component)]
pub struct Cost(u32);
#[derive(Component)]
pub struct FireRate {
    rate: f32,
    firing_type: FiringType,
}
#[derive(Component)]
pub struct Damage {
    value: f32,
    damage_type: DamageType,
}
#[derive(Component)]
pub struct Range(f32);
#[derive(Component)]
pub struct Level(u32);
#[derive(Component)]
pub struct StatChanges(Vec<StatChange>);

#[derive(Event, Default)]
pub struct AttackEvent;

#[derive(Bundle)]
pub struct TowerBundle {
    cost: Cost,
    fire_rate: FireRate,
    damage: Damage,
    range: Range,
    level: Level,
    stat_changes: StatChanges,
}

impl TowerBundle {}
