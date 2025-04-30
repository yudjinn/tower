pub mod tower;

use std::ops::Add;

use bevy::{
    prelude::*,
    sprite::{MaterialMesh2dBundle, Mesh2dHandle},
};

fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_systems(Startup, setup)
        .add_systems(Update, move_circle)
        .run();
}

#[derive(Component)]
struct Position(Vec2);

#[derive(Component)]
struct Ball {
    radius: f32,
}

#[derive(Component)]
struct BallBundle {
    ball: Ball,
    position: Position,
}

fn move_circle(mut circle: Query<&mut Position, With<Ball>>) {
    if let Ok(mut transform) = circle.get_single_mut() {
        transform.0.x += 1.0
    }
}

const X_EXTENT: f32 = 600.;

fn setup(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<ColorMaterial>>,
) {
    commands.spawn(Camera2dBundle::default());
}
