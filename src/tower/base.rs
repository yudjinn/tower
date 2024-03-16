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
    StaggeredProjectile,
    Spread,
    Beam,
    Nova,
    Chain,
    Aura, // similar to nova, but a different logical check
}

pub trait Tower {
    fn cost(&self) -> u32;

    fn fire_rate(&self) -> f32;

    fn damage(&self) -> f32;

    fn range(&self) -> f32;

    fn set_level(&mut self, level: u32);

    fn damage_type(&self) -> &DamageType;

    fn firing_type(&self) -> &FiringType;

    fn new() -> Self;

    fn stat_changes(&self) -> &Vec<StatChange>;
}

#[derive(Clone, Copy, PartialEq, PartialOrd)]
pub enum StatChangeType {
    DamageChangePercent,
    FireRateChangePercent,
    RangeChangePercent,
    CostChangePercent,
}

pub struct StatChange {
    pub value: f32,
    pub stat_change_type: StatChangeType,
}

impl StatChange {
    pub fn with_stat_change(stat_changes: Vec<&StatChange>, base: f32) -> f32 {
        let delta: f32 = stat_changes.iter().map(|s| s.value).product();
        let prod: f32 = base as f32 * delta;
        prod.floor()
    }
}
