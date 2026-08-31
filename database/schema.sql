-- Extension pour la gestion des UUID (Identifiants uniques)
create extension if not exists "uuid-ossp";

-- 1. PROFILS UTILISATEURS (Lié à la table auth.users de Supabase)
create table public.users (
    id uuid references auth.users on delete cascade primary key,
    email text unique not null,
    full_name text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. SPÉCIFICATIONS TECHNIQUES DES VÉHICULES (Référentiel mondial)
create table public.vehicle_specs (
    id uuid default uuid_generate_v4() primary key,
    make text not null, -- Ex: Peugeot
    model text not null, -- Ex: 208
    year integer not null,
    engine_type text, -- Ex: 1.2 PureTech
    oil_type text, -- Ex: 0W30
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. VÉHICULES DES UTILISATEURS (Mon Garage)
create table public.vehicles (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.users(id) on delete cascade not null,
    license_plate text not null,
    vin text,
    spec_id uuid references public.vehicle_specs(id) on delete set null,
    current_mileage integer default 0 not null,
    mecago_score integer default 100 not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. TUTORIELS (Catalogue global)
create table public.tutorials (
    id uuid default uuid_generate_v4() primary key,
    title text not null, -- Ex: Vidange moteur
    category text not null, -- Ex: Moteur
    estimated_time text not null, -- Ex: 45 min
    difficulty text not null, -- Ex: Intermédiaire
    tools_needed text[] not null, -- Liste d'outils
    warnings text[],
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. ÉTAPES DES TUTORIELS
create table public.tutorial_steps (
    id uuid default uuid_generate_v4() primary key,
    tutorial_id uuid references public.tutorials(id) on delete cascade not null,
    step_number integer not null,
    instruction text not null,
    image_url text,
    is_critical boolean default false not null,
    constraint unique_step_per_tutorial unique (tutorial_id, step_number)
);

-- 6. HISTORIQUE DES INTERVENTIONS
create table public.service_history (
    id uuid default uuid_generate_v4() primary key,
    vehicle_id uuid references public.vehicles(id) on delete cascade not null,
    tutorial_id uuid references public.tutorials(id) on delete set null,
    title_custom text, -- Si l'utilisateur fait un entretien hors catalogue
    mileage_at_service integer not null,
    cost_estimated numeric(10,2) default 0.00 not null, -- Économies
    completed_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 7. RAPPELS D'ENTRETIEN
create table public.reminders (
    id uuid default uuid_generate_v4() primary key,
    vehicle_id uuid references public.vehicles(id) on delete cascade not null,
    title text not null,
    target_mileage integer,
    target_date date,
    is_triggered boolean default false not null
);

-- Activer la sécurité Row Level Security (RLS) sur Supabase
alter table public.users enable row level security;
alter table public.vehicles enable row level security;
alter table public.service_history enable row level security;
alter table public.reminders enable row level security;

-- Exemple de politique RLS : Un utilisateur ne peut voir que ses propres véhicules
create policy "Les utilisateurs voient leurs propres véhicules" on public.vehicles
    for all using (auth.uid() = user_id);
