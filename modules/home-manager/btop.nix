{ config, pkgs, ... }:

{
  # Btop configuration
  # Btop is already installed via system packages in modules/nixos/system.nix
  # This module provides configuration for btop
  
  xdg.configFile."btop/btop.conf".text = ''
    #? Config file for btop v. 1.2.2
    # Btop configuration for Frog-OS

    #* Color theme
    color_theme = "Default"

    #* Show theme background
    theme_background = True

    #* Enable 24-bit truecolor
    truecolor = True

    #* Update interval in milliseconds
    update_ms = 2000

    #* Processes sorting
    proc_sorting = "cpu lazy"

    #* Show processes as tree
    proc_tree = False

    #* Use colors for process list
    proc_colors = True

    #* Use gradient colors
    proc_gradient = True

    #* Show process memory as bytes
    proc_mem_bytes = True

    #* Show CPU graph for each process
    proc_cpu_graphs = True

    #* Filter out kernel threads
    proc_filter_kthreads = True

    #* Show CPU box
    cpu_box = True

    #* Show CPU temperature
    cpu_sensor = True

    #* Show temperatures for CPU cores
    cpu_core_map = True

    #* Show memory box
    mem_box = True

    #* Show memory graphs
    mem_graphs = True

    #* Show network box
    net_box = True

    #* Show download stats
    net_download = True

    #* Show processes box
    proc_box = True

    #* Rounded corners
    rounded_corners = True

    #* Graph symbol style
    graph_symbol = "braille"

    #* Boxes to show
    shown_boxes = "cpu mem net proc"
  '';
}
