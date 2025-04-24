pub enum ArmorType {
    Standard,
    Light,
    Heavy,
    Shield,
}

pub enum DeathEffectType {
    ExplosionDamage { damage: usize },
    SpeedUp { percent: usize },
    AreaHeal { amount: usize },
    TowerStun { duration: usize },
}

pub struct DeathEffect {
    radius: f32,
    death_effect_type: DeathEffectType,
}

pub trait Mob {
    fn armor_type(&self) -> &ArmorType;
    fn movement_speed(&self) -> f32;
    fn health(&self) -> f32;
    fn is_alive(&self) -> bool;
    fn death_effects(&self) -> &Vec<DeathEffect>;
}
