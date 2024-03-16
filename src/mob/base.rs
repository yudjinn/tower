// TODO: Move this to mob stuffs
pub enum ArmorType {
    Standard,
    Light,
    Heavy,
    Shield,
}

pub enum DeathEffectType {
    ExplosionDamage,
    SpeedUp,
    AreaHeal,
    TowerStun,
}

pub struct DeathEffect {
    radius: f32,
    // only pertinent for some effect types
    value: Option<f32>,
    death_effect_type: DeathEffectType,
}

trait Mob {
    fn armor_type(&self) -> &ArmorType;
    fn movement_speed(&self) -> f32;
    fn health(&self) -> f32;
    fn is_alive(&self) -> bool;
    fn death_effects(&self) -> &Vec<DeathEffect>;
}
