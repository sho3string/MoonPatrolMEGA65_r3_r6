----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Wrapper for the MiSTer core that runs exclusively in the core's clock domanin
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.video_modes_pkg.all;

entity main is
   generic (
      G_VDNUM                 : natural                     -- amount of virtual drives
   );
   port (
      clk_main_i              : in  std_logic;
      clk_sound_i             : in  std_logic;
      reset_soft_i            : in  std_logic;
      reset_hard_i            : in  std_logic;
      pause_i                 : in  std_logic;

      -- MiSTer core main clock speed:
      -- Make sure you pass very exact numbers here, because they are used for avoiding clock drift at derived clocks
      clk_main_speed_i        : in  natural;

      video_ce_i              : in  std_logic;
      -- Video output
      video_ce_o              : out std_logic;
      video_ce_ovl_o          : out std_logic;
      video_red_o             : out std_logic_vector(3 downto 0);
      video_green_o           : out std_logic_vector(3 downto 0);
      video_blue_o            : out std_logic_vector(3 downto 0);
      video_vs_o              : out std_logic;
      video_hs_o              : out std_logic;
      video_hblank_o          : out std_logic;
      video_vblank_o          : out std_logic;

      -- Audio output (Signed PCM)
      audio_left_o            : out signed(15 downto 0);
      audio_right_o           : out signed(15 downto 0);

      -- M2M Keyboard interface
      kb_key_num_i            : in  integer range 0 to 79;    -- cycles through all MEGA65 keys
      kb_key_pressed_n_i      : in  std_logic;                -- low active: debounced feedback: is kb_key_num_i pressed right now?

      -- MEGA65 joysticks and paddles/mouse/potentiometers
      joy_1_up_n_i            : in  std_logic;
      joy_1_down_n_i          : in  std_logic;
      joy_1_left_n_i          : in  std_logic;
      joy_1_right_n_i         : in  std_logic;
      joy_1_fire_n_i          : in  std_logic;

      joy_2_up_n_i            : in  std_logic;
      joy_2_down_n_i          : in  std_logic;
      joy_2_left_n_i          : in  std_logic;
      joy_2_right_n_i         : in  std_logic;
      joy_2_fire_n_i          : in  std_logic;

      pot1_x_i                : in  std_logic_vector(7 downto 0);
      pot1_y_i                : in  std_logic_vector(7 downto 0);
      pot2_x_i                : in  std_logic_vector(7 downto 0);
      pot2_y_i                : in  std_logic_vector(7 downto 0);
      
      dn_clk_i                : in  std_logic;
      dn_addr_i               : in  std_logic_vector(15 downto 0);
      dn_data_i               : in  std_logic_vector(7 downto 0);
      dn_wr_i                 : in  std_logic;

      osm_control_i           : in  std_logic_vector(255 downto 0)
   );
end entity main;

architecture synthesis of main is

-- @TODO: Remove these demo core signals
signal keyboard_n          : std_logic_vector(79 downto 0);
signal pause_cpu           : std_logic;
signal audio               : signed(12 downto 0);
signal reset               : std_logic := reset_hard_i or reset_soft_i;

-- highscore system
signal hs_address          : std_logic_vector(10 downto 0);
signal hs_data_in          : std_logic_vector(7 downto 0);
signal hs_data_out         : std_logic_vector(7 downto 0);
signal hs_write_enable     : std_logic;
signal hs_access_read      : std_logic;
signal hs_access_write     : std_logic;

signal hs_pause            : std_logic;
signal options             : std_logic_vector(1 downto 0);

-- Game player inputs
constant m65_1             : integer := 56; --Player 1 Start
constant m65_2             : integer := 59; --Player 2 Start
constant m65_5             : integer := 16; --Insert coin 1
constant m65_6             : integer := 19; --Insert coin 2

-- Offer some keyboard controls in addition to Joy 1 Controls
constant m65_up_crsr       : integer := 73; --Player up
constant m65_vert_crsr     : integer := 7;  --Player down
constant m65_left_crsr     : integer := 74; --Player left
constant m65_horz_crsr     : integer := 2;  --Player right
constant m65_mega          : integer := 61; --Trigger 1
constant m65_space         : integer := 60; --Trigger 2
constant m65_p             : integer := 41; --Pause button
constant m65_s             : integer := 13; --Service 1
constant m65_d             : integer := 18; --Service Mode

-- Menu controls
constant C_MENU_OSMPAUSE   : natural := 2;
constant C_MENU_PALMODE    : natural := 46;

constant C_MENU_H2         : integer := 31;
constant C_MENU_H4         : integer := 32;
constant C_MENU_H8         : integer := 33;
constant C_MENU_H16        : integer := 34;

constant C_MENU_V2         : integer := 40;
constant C_MENU_V4         : integer := 41;
constant C_MENU_V8         : integer := 42;
constant C_MENU_V16        : integer := 43;

signal HPOS,VPOS              : std_logic_vector(3 downto 0);
signal JOY                    : std_logic_vector(7 downto 0);
signal JOY2                   : std_logic_vector(7 downto 0);
signal dual_controls          : std_logic;
signal p1_jump_auto           : std_logic;
signal p2_jump_auto           : std_logic;
signal trigger_sel            : std_logic_vector(3 downto 0);
signal trigger_en             : std_logic;
signal pal_mode               : std_logic;

begin
    
    audio_left_o(15 downto 0) <= audio(12 downto 0) & "000";
    audio_right_o(15 downto 0) <= audio(12 downto 0) & "000";
    
    options(0)  <= osm_control_i(C_MENU_OSMPAUSE);
    pal_mode    <= osm_control_i(C_MENU_PALMODE);

    -- video crt offsets
    HPOS <=    osm_control_i(C_MENU_H16)  &
               osm_control_i(C_MENU_H8)   &
               osm_control_i(C_MENU_H4)   &
               osm_control_i(C_MENU_H2);
              
               
    VPOS <=    osm_control_i(C_MENU_V16)  &
               osm_control_i(C_MENU_V8)   &
               osm_control_i(C_MENU_V4)   &
               osm_control_i(C_MENU_V2);
            
    i_pause : entity work.pause
    generic map (
     
        RW  => 4,
        GW  => 4,
        BW  => 4,
        CLKSPD => 30
        
     )         
     port map (
     clk_sys        => clk_main_i,
     reset          => reset,
     user_button    => keyboard_n(m65_p),
     pause_request  => hs_pause,
     options        => options,
     OSD_STATUS     => '0',
     r              => video_red_o,
     g              => video_green_o,
     b              => video_blue_o,
     pause_cpu      => pause_cpu,
     dim_video      => dim_video_o
    );


    i_MoonPatrol : entity work.target_top
    port map (
    
    clock_30     => clk_main_i,
    clock_v      => video_ce_i,
    clock_3p58   => clk_sound_i,
    reset        => reset,
    dn_addr      => dn_addr_i,
    dn_data      => dn_data_i,
    dn_wr        => dn_wr_i,
    dn_clk       => dn_clk_i,
   
    JOY(7)       => not keyboard_n(m65_5),
    JOY(6)       => not keyboard_n(m65_1),
    JOY(5)       => not keyboard_n(m65_space) or not joy_1_up_n_i,
    JOY(4)       => not joy_1_fire_n_i or not keyboard_n(m65_mega),
    JOY(3)       => not joy_1_up_n_i,
    JOY(2)       => not joy_1_down_n_i,
    JOY(1)       => not joy_1_left_n_i,
    JOY(0)       => not joy_1_right_n_i,
    
    JOY2(7)      => not keyboard_n(m65_6),
    JOY2(6)      => not keyboard_n(m65_2),
    JOY2(5)      => not keyboard_n(m65_space) or not joy_2_up_n_i,
    JOY2(4)      => not joy_2_fire_n_i or not keyboard_n(m65_mega),
    JOY2(3)      => not joy_2_up_n_i,
    JOY2(2)      => not joy_2_down_n_i,
    JOY2(1)      => not joy_2_left_n_i,
    JOY2(0)      => not joy_2_right_n_i,
    
    VGA_R        => video_red_o,
	VGA_G        => video_green_o,
	VGA_B        => video_blue_o,
	VGA_HS       => video_hs_o,
	VGA_VS       => video_vs_o,
	VGA_HBLANK   => video_hblank_o,
	VGA_VBLANK   => video_vblank_o,
    
    palmode      => pal_mode,
    hs_offset    => HPOS,
    vs_offset    => VPOS,
    
    audio        => audio,

    PAUSE        => pause_cpu or pause_i,
    
    hs_address   => hs_address,
    hs_data_out  => hs_data_out,
    hs_data_in   => hs_data_in,
    hs_write     => hs_write_enable
   );
 
    /*i_hiscore : entity work.hiscore
    port map (
        clk             => clk_main_i,
        reset           => reset,
        paused          => pause_cpu,
        autosave        => '0',
        ram_address     => hs_address(9 downto 0),
        data_from_ram   => hs_data_out,
        data_from_hps   => dn_data_i,
        data_to_hps     => open,
        ram_write       => hs_write_enable,
        ram_intent_read => hs_access_read,
	    ram_intent_write=> hs_access_write,
	    pause_cpu       => hs_pause,
	    configured      => open,
	    ioctl_upload    => '0',
	    ioctl_download  => '0',
	    ioctl_wr        => dn_wr_i,
	    ioctl_addr      => dn_addr_i,
	    ioctl_index     => "0",
	    OSD_STATUS      => '0'
    );*/

   -- @TODO: Keyboard mapping and keyboard behavior
   -- Each core is treating the keyboard in a different way: Some need low-active "matrices", some
   -- might need small high-active keyboard memories, etc. This is why the MiSTer2MEGA65 framework
   -- lets you define literally everything and only provides a minimal abstraction layer to the keyboard.
   -- You need to adjust keyboard.vhd to your needs
   i_keyboard : entity work.keyboard
      port map (
         clk_main_i           => clk_main_i,

         -- Interface to the MEGA65 keyboard
         key_num_i            => kb_key_num_i,
         key_pressed_n_i      => kb_key_pressed_n_i,

         -- @TODO: Create the kind of keyboard output that your core needs
         -- "example_n_o" is a low active register and used by the demo core:
         --    bit 0: Space
         --    bit 1: Return
         --    bit 2: Run/Stop
         example_n_o          => keyboard_n
      ); -- i_keyboard

end architecture synthesis;

