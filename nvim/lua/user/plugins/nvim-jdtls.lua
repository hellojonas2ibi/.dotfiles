-- See `:help vim.lsp.start` for an overview of the supported `config` options.

local function setup()
	local jdtls_ok, _ = pcall(require, "jdtls")

	if not jdtls_ok then
		vim.notify("JDTLS not found, install with `:MasonInstall jdtls`")
		return
	end

	local isWin = package.config:sub(1, 1) == "\\"
	local config_folder = "config_linux"

	if isWin then
		config_folder = "config_win"
	end

	local data_dir = vim.fn.stdpath("data")
	local jdtls_root = vim.fs.joinpath(data_dir, "mason", "packages", "jdtls")
	local lombok_path = vim.fs.joinpath(jdtls_root, "lombok.jar")
	local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
	local config_path = vim.fs.joinpath(jdtls_root, config_folder)
	local root_dir = vim.fs.root(0, root_markers)

	if root_dir == "" then
		return
	end

	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	local workspace_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "java", "workspace", project_name)

	vim.fn.mkdir(workspace_dir, "p")

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	-- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
	-- capabilities.resolveAdditionalTextEditsSupport = true

	local launcher =
		vim.fn.glob(vim.fs.joinpath(jdtls_root, "plugins", "org.eclipse.equinox.launcher_*.jar"), true, true)[1]

	local java_cmd = "java"

	if isWin then
		java_cmd = vim.fs.joinpath("C:", "Program Files", "Java", "jdk-26.0.1", "bin", "java.exe")
	end

	local runtimes = {}
	if isWin then
		runtimes = {
			{
				name = "JavaSE-1.8",
				path = "C:/Program Files/Java/jdk1.8.0_202/",
			},
			{
				name = "JavaSE-17",
				path = "C:/Program Files/Java/jdk-17.0.5/",
			},
		}
	else
		runtimes = {
			{
				name = "JavaSE-1.8",
				path = "/usr/lib/jvm/java-8-openjdk/",
			},
			{
				name = "JavaSE-17",
				path = "/usr/lib/jvm/java-17-openjdk/",
			},
		}
	end

	local config = {
		name = "jdtls",

		-- `cmd` defines the executable to launch eclipse.jdt.ls.
		-- `jdtls` must be available in $PATH and you must have Python3.9 for this to work.
		--
		-- As alternative you could also avoid the `jdtls` wrapper and launch
		-- eclipse.jdt.ls via the `java` executable
		-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
		cmd = {
			-- "java",
			java_cmd,
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dosgi.checkConfiguration=true",
			"-Dosgi.sharedConfiguration.area=" .. config_path,
			"-Dosgi.sharedConfiguration.area.readOnly=true",
			"-Dosgi.configuration.cascaded=true",
			"-Xms1G",
			"--add-modules=ALL-SYSTEM",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
			"-javaagent:" .. lombok_path,
			"-jar",
			launcher,
			"-configuration",
			config_path,
			"-data",
			workspace_dir,
		},

		-- `root_dir` must point to the root of your project.
		-- See `:help vim.fs.root`
		root_dir = root_dir,

		-- Here you can configure eclipse.jdt.ls specific settings
		-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
		-- for a list of options
		settings = {
			java = {
				configuration = {
					runtimes = runtimes,
				},
			},
			capabilities = capabilities,
		},

		-- This sets the `initializationOptions` sent to the language server
		-- If you plan on using additional eclipse.jdt.ls plugins like java-debug
		-- you'll need to set the `bundles`
		--
		-- See https://codeberg.org/mfussenegger/nvim-jdtls#java-debug-installation
		--
		-- If you don't plan on any eclipse.jdt.ls plugins you can remove this
		init_options = {
			bundles = {},
			extendedClientCapabilities = capabilities,
		},
	}

	local javalsp_group = vim.api.nvim_create_augroup("JavaLSP", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "java" },
		callback = function(_)
			require("jdtls").start_or_attach(config)
		end,
		group = javalsp_group,
	})
end

return {
	"mfussenegger/nvim-jdtls",
	config = setup,
}
