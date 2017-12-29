data:extend({
    {
        type = "bool-setting",
        name = "recexplo-show-hidden",
        setting_type = "runtime-per-user",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "recexplo-enable-experimental-features",
        setting_type = "runtime-per-user",
        default_value = false
    },
    {
        type = "int-setting",
        name = "recexplo-amount-displayed-recipes",
        setting_type = "runtime-per-user",
        default_value = 20,
        minimum_value = 1
    },
    {
        type = "int-setting",
        name = "recexplo-amount-of-recipes-columns",
        setting_type = "runtime-per-user",
        default_value = 4,
        minimum_value = 1
    },
    {
        type = "string-setting",
        name = "recexplo-window-resolution-height",
        setting_type = "runtime-per-user",
        default_value = "600",
        allowed_values = {"300","400","500","600","700","800","900", "1000", "1100", "1200"}
    }
})