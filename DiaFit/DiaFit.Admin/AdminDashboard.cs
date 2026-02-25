using System.Net.Http.Headers;
using System.Text.Json;

namespace DiaFit.Admin
{
    public partial class AdminDashboard : Form
    {
        private readonly HttpClient _http = new();
        private string _token = string.Empty;
        private const string ApiBase = "http://localhost:5103/api";

        private Panel pnlSidebar = null!;
        private Panel pnlMain = null!;
        private Label lblTitle = null!;
        private DataGridView dataGrid = null!;
        private Label lblStatus = null!;
        private Button btnRefresh = null!;
        private TextBox txtEmail = null!, txtPassword = null!;
        private Button btnLogin = null!;
        private Panel pnlLogin = null!;

        public AdminDashboard()
        {
            Text = "DiaFit Admin Dashboard";
            Size = new Size(1200, 750);
            BackColor = Color.FromArgb(13, 27, 42);
            StartPosition = FormStartPosition.CenterScreen;
            BuildUI();
        }

        void BuildUI()
        {
            // Login Panel
            pnlLogin = new Panel { Dock = DockStyle.Fill, BackColor = Color.FromArgb(13, 27, 42) };

            var loginCard = new Panel { Width = 360, Height = 340, BackColor = Color.FromArgb(26, 41, 64) };
            loginCard.Location = new Point((ClientSize.Width - loginCard.Width) / 2, (ClientSize.Height - loginCard.Height) / 2);
            loginCard.Anchor = AnchorStyles.None;

            var logo = new Label { Text = "🩺 DiaFit Admin", Font = new Font("Segoe UI", 18, FontStyle.Bold), ForeColor = Color.FromArgb(0, 212, 255), AutoSize = true };
            logo.Location = new Point(50, 30);

            var emailLabel = new Label { Text = "Admin Email", ForeColor = Color.FromArgb(136, 153, 170), AutoSize = true, Location = new Point(30, 100) };
            txtEmail = new TextBox { Location = new Point(30, 120), Width = 300, BackColor = Color.FromArgb(13, 27, 42), ForeColor = Color.White, BorderStyle = BorderStyle.FixedSingle };
            txtEmail.Text = "admin@diafit.com";

            var passLabel = new Label { Text = "Password", ForeColor = Color.FromArgb(136, 153, 170), AutoSize = true, Location = new Point(30, 160) };
            txtPassword = new TextBox { Location = new Point(30, 180), Width = 300, PasswordChar = '●', BackColor = Color.FromArgb(13, 27, 42), ForeColor = Color.White, BorderStyle = BorderStyle.FixedSingle };
            txtPassword.Text = "Admin@123";

            btnLogin = new Button { Text = "Sign In →", Location = new Point(30, 240), Width = 300, Height = 44, BackColor = Color.FromArgb(0, 212, 255), ForeColor = Color.Black, FlatStyle = FlatStyle.Flat, Font = new Font("Segoe UI", 11, FontStyle.Bold), Cursor = Cursors.Hand };
            btnLogin.FlatAppearance.BorderSize = 0;
            btnLogin.Click += async (_, __) => await LoginAsync();

            loginCard.Controls.AddRange(new Control[] { logo, emailLabel, txtEmail, passLabel, txtPassword, btnLogin });
            pnlLogin.Controls.Add(loginCard);
            Controls.Add(pnlLogin);

            // Sidebar
            pnlSidebar = new Panel { Width = 220, Dock = DockStyle.Left, BackColor = Color.FromArgb(16, 30, 50), Visible = false };
            var sideTitle = new Label { Text = "🩺 DiaFit Admin", Font = new Font("Segoe UI", 12, FontStyle.Bold), ForeColor = Color.FromArgb(0, 212, 255), Location = new Point(16, 20), AutoSize = true };
            pnlSidebar.Controls.Add(sideTitle);

            string[] navItems = { "📊 Dashboard", "👥 Users", "💧 Health Logs", "🍽️ Diet Logs", "💊 Medications" };
            int y = 70;
            foreach (var item in navItems)
            {
                var btn = new Button { Text = item, Location = new Point(10, y), Width = 200, Height = 40, BackColor = Color.Transparent, ForeColor = Color.FromArgb(180, 200, 220), FlatStyle = FlatStyle.Flat, TextAlign = ContentAlignment.MiddleLeft, Font = new Font("Segoe UI", 10), Cursor = Cursors.Hand, Padding = new Padding(12, 0, 0, 0) };
                btn.FlatAppearance.BorderSize = 0;
                var capturedItem = item;
                btn.Click += async (_, __) => await LoadSection(capturedItem);
                btn.MouseEnter += (_, __) => btn.ForeColor = Color.FromArgb(0, 212, 255);
                btn.MouseLeave += (_, __) => btn.ForeColor = Color.FromArgb(180, 200, 220);
                pnlSidebar.Controls.Add(btn);
                y += 48;
            }

            // Main panel
            pnlMain = new Panel { Dock = DockStyle.Fill, BackColor = Color.FromArgb(13, 27, 42), Visible = false };

            lblTitle = new Label { Text = "Dashboard", Font = new Font("Segoe UI", 18, FontStyle.Bold), ForeColor = Color.White, Location = new Point(24, 20), AutoSize = true };

            btnRefresh = new Button { Text = "⟳ Refresh", Location = new Point(900, 22), Width = 110, Height = 36, BackColor = Color.FromArgb(0, 212, 255), ForeColor = Color.Black, FlatStyle = FlatStyle.Flat, Font = new Font("Segoe UI", 10, FontStyle.Bold), Cursor = Cursors.Hand };
            btnRefresh.FlatAppearance.BorderSize = 0;
            btnRefresh.Click += async (_, __) => await LoadSection(lblTitle.Text);

            dataGrid = new DataGridView
            {
                Location = new Point(24, 80), Width = 940, Height = 560, BackgroundColor = Color.FromArgb(26, 41, 64),
                ForeColor = Color.White, GridColor = Color.FromArgb(45, 64, 96), BorderStyle = BorderStyle.None,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill, ReadOnly = true, AllowUserToAddRows = false,
                ColumnHeadersDefaultCellStyle = new DataGridViewCellStyle { BackColor = Color.FromArgb(0, 212, 255), ForeColor = Color.Black, Font = new Font("Segoe UI", 9, FontStyle.Bold) },
                DefaultCellStyle = new DataGridViewCellStyle { BackColor = Color.FromArgb(26, 41, 64), ForeColor = Color.White, SelectionBackColor = Color.FromArgb(0, 100, 140), SelectionForeColor = Color.White },
                RowHeadersVisible = false, EnableHeadersVisualStyles = false, Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right | AnchorStyles.Bottom
            };

            lblStatus = new Label { Text = "Ready", ForeColor = Color.FromArgb(136, 153, 170), Location = new Point(24, 650), AutoSize = true };

            pnlMain.Controls.AddRange(new Control[] { lblTitle, btnRefresh, dataGrid, lblStatus });
            Controls.AddRange(new Control[] { pnlSidebar, pnlMain });
        }

        async Task LoginAsync()
        {
            btnLogin.Enabled = false;
            btnLogin.Text = "Signing in...";
            try
            {
                var body = JsonSerializer.Serialize(new { email = txtEmail.Text, password = txtPassword.Text });
                var content = new StringContent(body, System.Text.Encoding.UTF8, "application/json");
                var res = await _http.PostAsync($"{ApiBase}/auth/login", content);
                if (res.IsSuccessStatusCode)
                {
                    var json = JsonSerializer.Deserialize<JsonElement>(await res.Content.ReadAsStringAsync());
                    _token = json.GetProperty("token").GetString() ?? "";
                    _http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _token);
                    pnlLogin.Visible = false;
                    pnlSidebar.Visible = true;
                    pnlMain.Visible = true;
                    await LoadSection("📊 Dashboard");
                }
                else
                {
                    MessageBox.Show("Login failed. Check credentials.", "Auth Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            catch { MessageBox.Show("Cannot connect to API. Is the API running?", "Connection Error", MessageBoxButtons.OK, MessageBoxIcon.Error); }
            finally { btnLogin.Enabled = true; btnLogin.Text = "Sign In →"; }
        }

        async Task LoadSection(string section)
        {
            lblTitle.Text = section.Replace("📊 ", "").Replace("👥 ", "").Replace("💧 ", "").Replace("🍽️ ", "").Replace("💊 ", "");
            lblStatus.Text = "Loading...";
            dataGrid.DataSource = null;

            try
            {
                string endpoint = section switch
                {
                    "👥 Users" => $"{ApiBase}/auth/users",
                    "💧 Health Logs" => $"{ApiBase}/healthlog",
                    "🍽️ Diet Logs" => $"{ApiBase}/dietlog",
                    "💊 Medications" => $"{ApiBase}/medicationlog",
                    _ => null!
                };

                if (section == "📊 Dashboard")
                {
                    ShowDashboardSummary();
                    lblStatus.Text = "Dashboard loaded.";
                    return;
                }

                if (endpoint != null)
                {
                    var res = await _http.GetAsync(endpoint);
                    if (res.IsSuccessStatusCode)
                    {
                        var raw = await res.Content.ReadAsStringAsync();
                        var list = JsonSerializer.Deserialize<List<JsonElement>>(raw);
                        if (list != null && list.Count > 0)
                        {
                            var table = new System.Data.DataTable();
                            foreach (var prop in list[0].EnumerateObject())
                                table.Columns.Add(prop.Name);
                            foreach (var item in list)
                            {
                                var row = table.NewRow();
                                foreach (var prop in item.EnumerateObject())
                                    row[prop.Name] = prop.Value.ToString();
                                table.Rows.Add(row);
                            }
                            dataGrid.DataSource = table;
                            lblStatus.Text = $"Loaded {list.Count} records.";
                        }
                        else
                        {
                            lblStatus.Text = "No records found.";
                        }
                    }
                    else lblStatus.Text = $"Error {res.StatusCode}";
                }
            }
            catch (Exception ex) { lblStatus.Text = $"Error: {ex.Message}"; }
        }

        void ShowDashboardSummary()
        {
            var table = new System.Data.DataTable();
            table.Columns.Add("Metric");
            table.Columns.Add("Status");
            table.Rows.Add("🩺 System", "Online");
            table.Rows.Add("📡 API", "Connected — http://localhost:5103");
            table.Rows.Add("🗄️ Database", "DiaFitDB (LocalDB)");
            table.Rows.Add("🔐 Auth", "JWT — 7 day token expiry");
            table.Rows.Add("🔒 Encryption", "AES-256 (Medical Notes)");
            dataGrid.DataSource = table;
        }
    }
}
