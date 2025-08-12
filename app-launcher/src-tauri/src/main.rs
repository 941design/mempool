#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::sync::Mutex;
use std::{env, fs};
use tauri::{Manager, WindowEvent, WindowUrl};
use tempfile::TempDir;
use tauri_plugin_log::LogTarget;

struct ProfileDir(Mutex<Option<TempDir>>);

fn main() {
    // create temp profile directory for this run
    let tmp = TempDir::new().expect("temp dir");
    let profile_path = tmp.path().to_path_buf();
    env::set_var("TEMP_PROFILE_DIR", &profile_path);

    tauri::Builder::default()
        .register_uri_scheme_protocol("app", |app, request| {
            let path = request
                .uri()
                .replace("app://", "")
                .trim_start_matches('/')
                .to_string();
            let asset = app
                .asset_resolver()
                .get(&path)
                .unwrap_or_else(|| app.asset_resolver().get("index.html").unwrap());
            tauri::http::ResponseBuilder::new()
                .mimetype(asset.mime_type())
                .body(asset.bytes().to_vec())
                .unwrap()
        })
        .plugin(
            tauri_plugin_log::Builder::new()
                .target(LogTarget::LogDir)
                .rotation_strategy(tauri_plugin_log::RotationStrategy::KeepAll)
                .build(),
        )
        .plugin(tauri_plugin_single_instance::init(|app, _args, _cwd| {
            if let Some(window) = app.get_window("main") {
                let _ = window.show();
                let _ = window.set_focus();
            }
        }))
        .manage(ProfileDir(Mutex::new(Some(tmp))))
        .setup(|app| {
            let url = if cfg!(debug_assertions) {
                let dev = env::var("FRONTEND_DEV_URL").expect("FRONTEND_DEV_URL");
                WindowUrl::External(dev.parse().unwrap())
            } else {
                WindowUrl::App("index.html".into())
            };
            tauri::WindowBuilder::new(app, "main", url)
                .title("Mempool")
                .inner_size(1280.0, 800.0)
                .resizable(true)
                .initialization_script(r#"document.addEventListener('dragover',e=>e.preventDefault());document.addEventListener('drop',e=>e.preventDefault());"#)
                .navigation_handler(|url| {
                    let allowed = ["app://", "http://localhost", "https://localhost"];
                    allowed.iter().any(|prefix| url.as_str().starts_with(prefix))
                })
                .build()?;
            Ok(())
        })
        .on_window_event(|event| {
            if let WindowEvent::CloseRequested { .. } = event.event() {
                let handle = event.window().app_handle();
                let state = handle.state::<ProfileDir>();
                if let Some(dir) = state.0.lock().unwrap().take() {
                    let path = dir.into_path();
                    let _ = fs::remove_dir_all(path);
                }
                std::process::exit(0);
            }
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
