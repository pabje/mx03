using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using CE.Model;
using System.Xml.Linq;
using CE.Business;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Threading;
using ClosedXML.Excel;
using System.IO;
using CE.Data;

namespace CE.WinFormUI
{
    public partial class Form1 : Form
    {
        private MainDB mainController;
        UtilitarioArchivos utileria;
        IList<vwComprobanteCFDI> listaDeCfdisFiltrados = null;
        short idxChkBox = 0;                    //columna check box del grid
        short idxTipo = 2;
        short idxUuid = 1;

        private List<ParametrosDeArchivo> lParametros = new List<ParametrosDeArchivo>();
        public Form1()
        {
            InitializeComponent();

        }
        private void MainController_eventoErrorDB(object sender, ErrorEventArgsEntidadesGP e)
        {
            lblProcesos.Text += e.mensajeError + Environment.NewLine;
        }

        private string companySelected()
        {
            return ((ComboBoxItem)cmbEmpresas.SelectedItem).Value;
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            bool error = false;
            int count = 1;
            while (!error)
            {
                if (System.Configuration.ConfigurationManager.ConnectionStrings["GP_" + count.ToString()] != null)
                {
                    LecturaContabilidadFactory oLC = new LecturaContabilidadFactory("GP_" + count.ToString());

                    cmbEmpresas.Items.Add(new ComboBoxItem("GP_" + count.ToString(), oLC.GetCompany()));
                    count++;
                }
                else
                    error = true;
            }

            cmbEmpresas.SelectedIndex = 0;
            lblUsuario.Text = Environment.UserDomainName + "\\" + Environment.UserName;
            lblFecha.Text = DateTime.Now.ToString("dd/MM/yyyy");

            lblProcesos.Text = "Iniciando carga de parámetros..." + Environment.NewLine;
            inicializarExportarXML();
            inicializarImportarXML();
            lblProcesos.Text = "Listo!" + Environment.NewLine;

        }

        private void cmbEmpresas_SelectedIndexChanged(object sender, EventArgs e)
        {
            cargarVista();
        }

        private void salirToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        #region Contabilidad Electrónica ExportarXML
        private void inicializarExportarXML()
        {
            for (int j = DateTime.Now.Year; j >= DateTime.Now.Year - 10; j--)
            {
                cmbAno.Items.Add(new ComboBoxItem(j.ToString(), j.ToString()));
            }

            cmbTipoDoc.Items.Add(new ComboBoxItem("-1", "-Todos-"));
            cmbTipoDoc.Items.Add(new ComboBoxItem("Catálogo", "Catálogo"));
            cmbTipoDoc.Items.Add(new ComboBoxItem("Balanza", "Balanza"));
            cmbTipoDoc.Items.Add(new ComboBoxItem("Pólizas", "Pólizas"));
            cmbTipoDoc.Items.Add(new ComboBoxItem("Auxiliar Cuentas", "Auxiliar Cuentas"));
            cmbTipoDoc.Items.Add(new ComboBoxItem("Auxiliar folios", "Auxiliar folios"));

            cmbTipoDoc.SelectedIndex = 2;
            cmbAno.SelectedIndex = 0;

            cmbAno.SelectedIndexChanged += new EventHandler(cmbAno_SelectedIndexChanged);
            cmbTipoDoc.SelectedIndexChanged += new EventHandler(cmbTipoDoc_SelectedIndexChanged);
            cmbEmpresas.SelectedIndexChanged += new EventHandler(cmbEmpresas_SelectedIndexChanged);

            cargarVista();

            string archivo1 = System.Configuration.ConfigurationManager.AppSettings[companySelected() + "_archivo1"].ToString();
            string archivo2 = System.Configuration.ConfigurationManager.AppSettings[companySelected() + "_archivo2"].ToString();
            string archivo3 = System.Configuration.ConfigurationManager.AppSettings[companySelected() + "_archivo3"].ToString();
            string archivo4 = System.Configuration.ConfigurationManager.AppSettings[companySelected() + "_archivo4"].ToString();
            string archivo5 = System.Configuration.ConfigurationManager.AppSettings[companySelected() + "_archivo5"].ToString();

            lParametros.Add(new ParametrosDeArchivo() { Tipo= "Catálogo", Archivo=archivo1, FuncionSql= "DCEMFCNCATALOGOXML", NameSpace= "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/CatalogoCuentas", Esquema= "CatalogoCuentas_1_3.xsd" });
            lParametros.Add(new ParametrosDeArchivo() { Tipo = "Balanza", Archivo = archivo2, FuncionSql = "DCEMFCNBALANCE", NameSpace= "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/BalanzaComprobacion", Esquema = "BalanzaComprobacion_1_3.xsd" });
            lParametros.Add(new ParametrosDeArchivo() { Tipo = "Pólizas", Archivo = archivo3, FuncionSql = "DCEMFCNPOLIZAS", NameSpace= "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/PolizasPeriodo", Esquema = "PolizasPeriodo_1_3.xsd" });
            lParametros.Add(new ParametrosDeArchivo() { Tipo = "Auxiliar Cuentas", Archivo = archivo4, FuncionSql = "DCEMFCNAUXILIARCTAS", NameSpace= "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarCtas", Esquema = "AuxiliarCtas_1_3.xsd" });
            lParametros.Add(new ParametrosDeArchivo() { Tipo = "Auxiliar folios", Archivo = archivo5, FuncionSql = "DCEMFCNAUXILIARFOLIOS", NameSpace= "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarFolios", Esquema = "AuxiliarFolios_1_3.xsd" });
        }

        private void cargarVista()
        {
            int ano = 0;

            if (Int32.Parse(((ComboBoxItem)cmbAno.SelectedItem).Value) != -1)
                ano = Int32.Parse(((ComboBoxItem)cmbAno.SelectedItem).Value);

            string tipo = ((ComboBoxItem)cmbTipoDoc.SelectedItem).Value;
            if (tipo == "-1")
                tipo = null;

            LecturaContabilidadFactory oL = new LecturaContabilidadFactory(companySelected());
            
            var l = oL.GetAll(ano, tipo);

            bindingSource2.DataSource = l;
            gridVista.AutoGenerateColumns = false;
            gridVista.DataSource = bindingSource2;
            gridVista.ClearSelection();
            gridVista.AutoResizeColumns();
        }

        void InicializaCheckBoxDelGrid(DataGridView dataGrid, short idxChkBox, bool marca)
        {
            for (int r = 0; r < dataGrid.RowCount; r++)
            {
                dataGrid[idxChkBox, r].Value = marca;
            }
            dataGrid.EndEdit();
            dataGrid.Refresh();
        }

        private object mostrarContenido(Int16 year1, Int16 periodid, string tipo)
        {
            string company = companySelected();
            object items = ContabilidadElectronicaPresentacion.ObtieneContenidoLinqDeXML(year1, periodid, tipo, company, lParametros);

            bindingSource1.DataSource = items;
            grid.AutoGenerateColumns = true;
            grid.DataSource = bindingSource1;
            grid.RowHeadersVisible = false;
            grid.AutoResizeColumns();

            return items;
        }

        private void mostrarMensaje()
        {
            XDocument xdoc = XDocument.Parse("<Mensajes><Mensaje texto = \"Para ver el contenido presione el botón Mostrar.\" /></Mensajes>");
            object items = null;
            items = xdoc.Descendants("Mensaje").Select(x => new { Atención = x.Attribute("texto").Value });

            bindingSource1.DataSource = items;
            grid.AutoGenerateColumns = true;
            grid.DataSource = bindingSource1;
            grid.RowHeadersVisible = false;
            grid.AutoResizeColumns();
        }

        private void gridVista_SelectionChanged(object sender, EventArgs e)
        {
            if (gridVista.SelectedRows.Count != 0)
            {
                try
                {
                    DcemVwContabilidad item = (DcemVwContabilidad)gridVista.SelectedRows[0].DataBoundItem;
                    if (item != null)
                        mostrarMensaje();
                    //mostrarContenido(item.year1, item.periodid, item.tipodoc);
                }
                catch
                {
                    grid.DataSource = null;
                }
            }
        }        

        private void cmbAno_SelectedIndexChanged(object sender, EventArgs e)
        {
            cargarVista();
        }

        private void cmbTipoDoc_SelectedIndexChanged(object sender, EventArgs e)
        {
            cargarVista();
        }

        private void gridVista_CellFormatting(object sender, DataGridViewCellFormattingEventArgs e)
        {
            if (e.ColumnIndex == 1)
            {
                DataGridView dgv = sender as DataGridView;
                DcemVwContabilidad data = dgv.Rows[e.RowIndex].DataBoundItem as DcemVwContabilidad;

                if (data != null && data.existe)
                {
                    dgv.Rows[e.RowIndex].DefaultCellStyle.BackColor = Color.LawnGreen;
                }
            }
        }

        private void tsButtonGenerar_Click(object sender, EventArgs e)
        {
            lblError.Text = "";
            lblProcesos.Text = "";

            LecturaContabilidadFactory oL = new LecturaContabilidadFactory(companySelected());
            oL.LParametros = lParametros;

            string directorio = System.Configuration.ConfigurationManager.AppSettings[companySelected() + "_directorio"].ToString();
            List<DcemVwContabilidad> l = new List<DcemVwContabilidad>();

            foreach (DataGridViewRow row in gridVista.Rows)
            {
                DataGridViewCheckBoxCell marca = row.Cells[0] as DataGridViewCheckBoxCell;
                
                if (marca.Value != null && (marca.Value.Equals(true) || marca.Value.ToString().Equals("1")))
                    {
                    var item = (DcemVwContabilidad)row.DataBoundItem;


                    if (item.tipodoc == "Pólizas" || item.tipodoc == "Auxiliar Cuentas" || item.tipodoc == "Auxiliar folios")
                    {
                        if (row.Cells[4].Value == null)
                        {
                            MessageBox.Show("Debe completar Tipo de Solicitud para periodo: " + item.periodid.ToString() + " año: " + item.year1.ToString() + " tipo doc: " + item.tipodoc);
                            return;
                        }
                        else
                        {
                            item.TipoSolicitud = row.Cells[4].Value.ToString();

                            string tipoSolicitud = row.Cells[4].Value.ToString().Substring(0, 2);
                            if (tipoSolicitud == "AF" || tipoSolicitud == "FC")
                            {
                                if (row.Cells[5].Value == null || row.Cells[5].Value.ToString() == "")
                                {
                                    MessageBox.Show("Debe completar N. Orden para periodo: " + item.periodid.ToString() + " año: " + item.year1.ToString() + " tipo doc: " + item.tipodoc);
                                    return;
                                }
                                else
                                {
                                    Regex rgx = new Regex(@"^[A-Z]{3}[0-9]{7}(/)[0-9]{2}$");

                                    if (!rgx.IsMatch(row.Cells[5].Value.ToString()))
                                    {
                                        MessageBox.Show("Debe completar N. Orden correctamente para periodo: " + item.periodid.ToString() + " año: " + item.year1.ToString() + " tipo doc: " + item.tipodoc);
                                        return;
                                    }
                                    else
                                    {
                                        item.NumOrden = row.Cells[5].Value.ToString();
                                    }
                                }
                            }
                            else
                            {
                                if (tipoSolicitud == "DE" || tipoSolicitud == "CO")
                                {
                                    if (row.Cells[6].Value == null || row.Cells[6].Value.ToString() == "")
                                    {
                                        MessageBox.Show("Debe completar N. Trámite para periodo: " + item.periodid.ToString() + " año: " + item.year1.ToString() + " tipo doc: " + item.tipodoc);
                                        return;
                                    }
                                    else
                                    {
                                        Regex rgx = new Regex(@"^[A-Z]{2}[0-9]{12}$");

                                        if (!rgx.IsMatch(row.Cells[6].Value.ToString()))
                                        {
                                            MessageBox.Show("Debe completar N. Trámite correctamente para periodo: " + item.periodid.ToString() + " año: " + item.year1.ToString() + " tipo doc: " + item.tipodoc);
                                            return;
                                        }
                                        else
                                        {
                                            item.NumTramite = row.Cells[6].Value.ToString();
                                        }
                                    }
                                }
                            }
                        }
                    }

                    l.Add(item);
                }
            }

            try
            {
                List<XmlExportado> xmls = oL.ProcesarArchivos(l, directorio, Application.StartupPath + "\\xsd\\");  //archivo1, archivo2, archivo3, archivo4, archivo5, 

                string errores = "";
                foreach (var xmle in xmls.Where(x => x.error))
                {
                    errores += " Año: " + xmle.DcemVwContabilidad.year1.ToString() + " Mes: " + xmle.DcemVwContabilidad.periodid.ToString() + " Tipo: " + xmle.DcemVwContabilidad.tipodoc + Environment.NewLine + xmle.mensaje + Environment.NewLine;
                    errores += "-----------------------------------------------------------------------" + Environment.NewLine;
                }
                lblError.Text = errores;

                lblProcesos.Text = "Carpeta de trabajo: " + directorio + Environment.NewLine;
                foreach (var xmle in xmls)
                {
                    lblProcesos.Text += " Año: " + xmle.DcemVwContabilidad.year1.ToString() + " Mes:" + xmle.DcemVwContabilidad.periodid.ToString() + " Tipo: " + xmle.DcemVwContabilidad.tipodoc + " Archivo: " + xmle.archivo + Environment.NewLine;
                    lblProcesos.Refresh();
                }

                foreach (DataGridViewRow row in gridVista.Rows)
                {
                    if (row.Cells[0].Value != null && row.Cells[0].Value.ToString() == "1")
                    {
                        row.DefaultCellStyle.BackColor = Color.Yellow;
                    }
                }

            }
            catch (Exception ex)
            {
                lblError.Text += ex.Message + Environment.NewLine;
            }


        }

        private void tsBtnMostrarContenido_Click(object sender, EventArgs e)
        {
            if (gridVista.SelectedRows.Count != 0)
            {
                try
                {
                    DcemVwContabilidad item = (DcemVwContabilidad)gridVista.SelectedRows[0].DataBoundItem;
                    if (item != null)
                        mostrarContenido(item.year1, item.periodid, item.tipodoc);
                }
                catch
                {
                    grid.DataSource = null;
                }
            }

        }

        #endregion

        #region IMPORTACION DE FACTURAS
        private void inicializarImportarXML()
        {
            utileria = new UtilitarioArchivos(@"http://www.sat.gob.mx/cfd/3", System.Configuration.ConfigurationManager.AppSettings[companySelected() + "_archivoXslt"].ToString());

        }

        private void MuestraContenidoCfdiXml()
        {
            if (gridFiles.SelectedRows.Count != 0)
            {
                var item = gridFiles.SelectedRows[0].DataBoundItem;
                if (item != null)
                {
                    System.Type type = item.GetType();
                    string archivo = (string)type.GetProperty("NOMBREARCHIVO").GetValue(item, null);
                    string directorio = (string)type.GetProperty("CARPETAARCHIVO").GetValue(item, null);

                    XNamespace cfdi = @"http://www.sat.gob.mx/cfd/3";
                    XNamespace pago10 = @"http://www.sat.gob.mx/Pagos";
                    XNamespace tfd = @"http://www.sat.gob.mx/TimbreFiscalDigital";

                    try
                    {
                        string text = System.IO.File.ReadAllText(directorio + "\\" + archivo);

                        XDocument xdoc = XDocument.Parse(text);
                        string tipoComprobante = GPCompras.AveriguarElTipoDeCfdi(xdoc, cfdi);
                        switch (tipoComprobante)
                        {
                            case "I":
                                var comprobante = (from c in xdoc.Descendants(cfdi + "Comprobante")
                                                   select new
                                                   {
                                                       Folio = c.Attribute("Folio") == null ? "" : c.Attribute("Folio").Value,
                                                       Fecha = c.Attribute("Fecha").Value,
                                                       FormaDePago = c.Attribute("FormaPago").Value,
                                                       CondicionesDePago = c.Attribute("CondicionesDePago") == null ? "" : c.Attribute("CondicionesDePago").Value,
                                                       SubTotal = c.Attribute("SubTotal").Value,
                                                       TipoCambio = c.Attribute("TipoCambio") == null ? "" : c.Attribute("TipoCambio").Value,
                                                       Moneda = c.Attribute("Moneda") == null ? "" : c.Attribute("Moneda").Value,
                                                       Total = c.Attribute("Total").Value,
                                                       TipoDeComprobante = c.Attribute("TipoDeComprobante").Value,
                                                       MetodoDePago = c.Attribute("MetodoPago").Value,
                                                       LugarExpedicion = c.Attribute("LugarExpedicion").Value
                                                   }).ToList();

                                var emisor = (from c in xdoc.Descendants(cfdi + "Emisor")
                                              select new
                                              {
                                                  Rfc = c.Attribute("Rfc").Value,
                                                  Nombre = c.Attribute("Nombre") == null ? "" : c.Attribute("Nombre").Value,
                                                  Regimen = c.Attribute("RegimenFiscal") == null ? "" : c.Attribute("RegimenFiscal").Value,
                                              }).ToList();

                                var receptor = (from c in xdoc.Descendants(cfdi + "Receptor")
                                                select new
                                                {
                                                    Rfc = c.Attribute("Rfc").Value,
                                                    Nombre = c.Attribute("Nombre") == null ? "" : c.Attribute("Nombre").Value
                                                }).ToList();

                                var concepto = (from c in xdoc.Descendants(cfdi + "Concepto")
                                                select new
                                                {
                                                    Cantidad = c.Attribute("Cantidad").Value,
                                                    Unidad = c.Attribute("ClaveUnidad").Value,
                                                    NoIdentificacion = c.Attribute("NoIdentificacion") == null ? "" : c.Attribute("NoIdentificacion").Value,
                                                    Descripcion = c.Attribute("Descripcion").Value,
                                                    ValorUnitario = c.Attribute("ValorUnitario").Value,
                                                    Importe = c.Attribute("Importe").Value
                                                }).ToList();

                                var retenciones = (from c in xdoc.Descendants(cfdi + "Impuestos").Where(x => x.Attribute("TotalImpuestosRetenidos") != null).Descendants(cfdi + "Retencion")
                                                   select new
                                                   {
                                                       Impuesto = c.Attribute("Impuesto").Value,
                                                       Importe = c.Attribute("Importe").Value
                                                   }).ToList();

                                var traslado = (from c in xdoc.Descendants(cfdi + "Impuestos").Where(x => x.Attribute("TotalImpuestosTrasladados") != null).Descendants(cfdi + "Traslado")
                                                select new
                                                {
                                                    Impuesto = c.Attribute("Impuesto").Value,
                                                    TipoFactor = c.Attribute("TipoFactor").Value,
                                                    Tasa = c.Attribute("TasaOCuota").Value,
                                                    Importe = c.Attribute("Importe").Value
                                                }).ToList();

                                var timbreDigital = (from c in xdoc.Descendants(tfd + "TimbreFiscalDigital")
                                                     select new
                                                     {
                                                         UUID = c.Attribute("UUID").Value
                                                     }).ToList();

                                dataGridView1.DataSource = comprobante;
                                dataGridView2.DataSource = emisor;
                                dataGridView3.DataSource = receptor;
                                dataGridView4.DataSource = concepto;
                                dataGridView5.DataSource = traslado;
                                dataGridView6.DataSource = retenciones;
                                dataGridView7.DataSource = timbreDigital;
                                dataGridView8.DataSource = null;
                                //dataGridView9.DataSource = ;
                                break;
                            case "P":
                                var comprobanteP = (from c in xdoc.Descendants(cfdi + "Comprobante")
                                                    select new
                                                    {
                                                        folio = c.Attribute("Folio") == null ? "" : c.Attribute("Folio").Value,
                                                        fecha = c.Attribute("Fecha").Value,
                                                        tipoDeComprobante = c.Attribute("TipoDeComprobante").Value,
                                                    }).ToList();


                                var emisorP = (from c in xdoc.Descendants(cfdi + "Emisor")
                                               select new
                                               {
                                                   Rfc = c.Attribute("Rfc").Value,
                                                   Nombre = c.Attribute("Nombre") == null ? "" : c.Attribute("Nombre").Value,
                                                   Regimen = c.Attribute("RegimenFiscal") == null ? "" : c.Attribute("RegimenFiscal").Value,
                                               }).ToList();

                                var receptorP = (from c in xdoc.Descendants(cfdi + "Receptor")
                                                 select new
                                                 {
                                                     Rfc = c.Attribute("Rfc").Value,
                                                     Nombre = c.Attribute("Nombre") == null ? "" : c.Attribute("Nombre").Value,
                                                     UsoCFDI = c.Attribute("UsoCFDI") == null ? "" : c.Attribute("UsoCFDI").Value,
                                                 }).ToList();

                                var conceptoP = (from c in xdoc.Descendants(cfdi + "Concepto")
                                                 select new
                                                 {
                                                     Cantidad = c.Attribute("Cantidad").Value,
                                                     Unidad = c.Attribute("ClaveUnidad").Value,
                                                     Producto = c.Attribute("ClaveProdServ") == null ? "" : c.Attribute("ClaveProdServ").Value,
                                                     Descripcion = c.Attribute("Descripcion").Value,
                                                 }).ToList();

                                var pagoP = (from c in xdoc.Descendants(pago10 + "Pago")
                                             select new
                                             {
                                                 CuentaDelBeneficiario = c.Attribute("CtaBeneficiario") == null ? "" : c.Attribute("CtaBeneficiario").Value,
                                                 RFCEmisorCuentaBeneficiario = c.Attribute("RfcEmisorCtaBen") == null ? "" : c.Attribute("RfcEmisorCtaBen").Value,
                                                 CuentaDelOrdenante = c.Attribute("CtaOrdenante") == null ? "" : c.Attribute("CtaOrdenante").Value,
                                                 RFCEmisorCuentaOrdenante = c.Attribute("RfcEmisorCtaOrd") == null ? "" : c.Attribute("RfcEmisorCtaOrd").Value,
                                                 NumeroDeOperacion = c.Attribute("NumOperacion") == null ? "" : c.Attribute("NumOperacion").Value,
                                                 Monto = c.Attribute("Monto").Value,
                                                 MonedaDelPago = c.Attribute("MonedaP").Value,
                                                 FormaDePagoP = c.Attribute("FormaDePagoP").Value,
                                                 FechaDelPago = c.Attribute("FechaPago").Value,
                                             }).ToList();

                                var docRelacionadoP = (from c in xdoc.Descendants(pago10 + "DoctoRelacionado")
                                                       select new
                                                       {
                                                           SaldoInsoluto = c.Attribute("ImpSaldoInsoluto") == null ? "" : c.Attribute("ImpSaldoInsoluto").Value,
                                                           Pagado = c.Attribute("ImpPagado") == null ? "" : c.Attribute("ImpPagado").Value,
                                                           SaldoAnterior = c.Attribute("ImpSaldoAnt") == null ? "" : c.Attribute("ImpSaldoAnt").Value,
                                                           Parcialidad = c.Attribute("NumParcialidad").Value,
                                                           MetodoDePago = c.Attribute("MetodoDePagoDR").Value,
                                                           TipoDeCambio = c.Attribute("TipoCambioDR") == null ? "" : c.Attribute("TipoCambioDR").Value,
                                                           Moneda = c.Attribute("MonedaDR").Value,
                                                           UUID = c.Attribute("IdDocumento").Value,
                                                       }).ToList();

                                var timbreDigitalP = (from c in xdoc.Descendants(tfd + "TimbreFiscalDigital")
                                                      select new
                                                      {
                                                          UUID = c.Attribute("UUID").Value
                                                      }).ToList();

                                dataGridView1.DataSource = comprobanteP;
                                dataGridView2.DataSource = emisorP;
                                dataGridView3.DataSource = receptorP;
                                dataGridView4.DataSource = pagoP;
                                dataGridView5.DataSource = null;
                                dataGridView6.DataSource = null;
                                dataGridView7.DataSource = timbreDigitalP;
                                dataGridView8.DataSource = docRelacionadoP;
                                ////dataGridView9.DataSource = ;

                                break;
                            default:
                                lblError.Text += "Este comprobante no se puede integrar a GP porque no es un comprobante de Ingreso ni de Pago" + Environment.NewLine;
                                lblError.Refresh();
                                break;
                        }
                    }
                    catch (IOException io)
                    {
                        lblError.Text += "Excepción al abrir el archivo XML. Es probable que el archivo no exista en la carpeta: " + directorio + Environment.NewLine + io.Message;
                        lblError.Refresh();
                    }
                    catch (Exception abr)
                    {
                        lblError.Text += "Excepción al abrir el archivo XML. Es probable que el xml no sea válido. Revise el archivo." + Environment.NewLine + abr.Message;
                        lblError.Refresh();
                    }
                }
            }
        }
        private void gridFiles_SelectionChanged(object sender, EventArgs e)
        {

                MuestraContenidoCfdiXml();

        }

        private void oL_ProcesoOkImportarPM(object sender, GPCompras.ProcesoOkImportarPMEventArgs e)
        {
            lblProcesos.Text += e.Archivo + " - Procesado - " + e.Msg + Environment.NewLine;
            lblProcesos.Text += "---------------------------" + Environment.NewLine;
            lblProcesos.Refresh();

            string directorio = System.Configuration.ConfigurationManager.AppSettings[companySelected() + "_directorioDestino"].ToString();

            if (!System.IO.Directory.Exists(directorio))
                System.IO.Directory.CreateDirectory(directorio);

            //el archivo quizas ya se movio cuando se exporto la factura, y vuelve a entrar porque se asigno folio
            if (!System.IO.File.Exists(directorio + "\\" + System.IO.Path.GetFileName(e.Archivo)))
                System.IO.File.Move(e.Archivo, directorio + "\\" + System.IO.Path.GetFileName(e.Archivo));
            //else
            //{
            //    try
            //    {
            //        System.IO.File.Delete(e.Archivo);
            //    }
            //    catch
            //    {
            //    }
            //}
        }

        private void oL_ErrorImportarPM(object sender, GPCompras.ErrorImportarPMEventArgs e)
        {
            lblError.Text += e.Archivo + ": " + e.Error + Environment.NewLine;
            lblError.Text += "---------------------------" + Environment.NewLine;
            lblError.Refresh();
        }

        //private async Task<List<Cfdi>> validaArchivosAsync(IProgress<int> prbar, UtilitarioArchivos utileria, List<Cfdi> listaCfdis)
        //{
        //    string archivo = String.Empty;
        //    string directorio = String.Empty;

        //    //carga y valida archivos
        //    int i = 1;
        //    int max = listaCfdis.Count;
        //    foreach (Cfdi row in listaCfdis)
        //    {
        //        try
        //        {
        //                var cmp = await utileria.CargarArchivoAsync(row.ArchivoYCarpeta);
        //                row.Valida = cmp.ValidaSelloAsync();

        //                if (prbar != null)
        //                {
        //                    prbar.Report(100 * i / max);
        //                }
        //                i++;
        //        }
        //        catch (Exception ex)
        //        {
        //            lblError.Text += "Excepción al leer "+ archivo + " " + ex.Message + Environment.NewLine;
        //        }
        //    }
        //    prbar.Report(0);
        //    return listaCfdis;
        //}

        private async void tsButtonSeleccionarArchivo_Click(object sender, EventArgs e)
        {
            LecturaContabilidadFactory contae = new LecturaContabilidadFactory(companySelected());

            GPCompras gpCompras = new GPCompras(companySelected());
            gpCompras.ErrorImportarPM += new EventHandler<GPCompras.ErrorImportarPMEventArgs>(oL_ErrorImportarPM);
            gpCompras.ProcesoOkImportarPM += new EventHandler<GPCompras.ProcesoOkImportarPMEventArgs>(oL_ProcesoOkImportarPM);

            lblError.Text = "";
            lblProcesos.Text = "";
            ReiniciarLaSeccionDelContenidoXml();
            tsProgressBar.Value = 0;

            openFileDialog1.Filter = "XML Files|*.xml";
            openFileDialog1.Multiselect = true;
            DialogResult dr = openFileDialog1.ShowDialog();

            if (dr == DialogResult.OK)
            {
                string[] filenames = openFileDialog1.FileNames;

                var archivosSeleccionados = from ff in filenames
                        select new { archivo = System.IO.Path.GetFileName(ff),
                                     directorio = System.IO.Path.GetDirectoryName(ff),
                                     };
                string carpetaDestino = System.Configuration.ConfigurationManager.AppSettings[companySelected() + "_directorioDestino"].ToString();

                var cfdisSeleccionados = archivosSeleccionados.Select(a => new Cfdi(utileria.Nscfdi, utileria.PlantillaXslt)
                                                   {ArchivoYCarpeta = Path.Combine(a.directorio, a.archivo),
                                                    ArchivoYCarpetaDestino = Path.Combine(carpetaDestino, a.archivo),
                                                    Valida = false,
                                                    } )
                                             .ToList();

                IProgress<int> prbar = new Progress<int>(p => tsProgressBar.Value = p);
                List<Cfdi> cfdisValidados = await gpCompras.validaArchivosAsync(prbar, utileria, cfdisSeleccionados);
                lblProcesos.Text += "Validaciones finalizadas." + Environment.NewLine;

                List<Cfdi> cfdisCargados = await gpCompras.CargarCfdisEnLogAsync(cfdisValidados, contae.GetRFC());
                lblProcesos.Text += "Carga de Cfdis en el log finalizada ." + Environment.NewLine;

                FiltrarComprobantes(true, cfdisCargados.Select(s => s.Uuid)
                                                       .ToList());

                lblProcesos.Text += "Listo para importar a GP."+Environment.NewLine;
            }

        }

        private int FiltrarComprobantes(bool ExisteLista, List<string> ComprobantesABuscar)
        {
            string efcnstring = System.Configuration.ConfigurationManager.AppSettings[companySelected() + "_UIEFConnString"].ToString();
            string pcnstring = System.Configuration.ConfigurationManager.ConnectionStrings[companySelected()].ToString();

            mainController = new MainDB("");
            mainController.connectionString = efcnstring + pcnstring + "application name=EntityFramework'";
            mainController.eventoErrDB += MainController_eventoErrorDB;

            bool cbFechaMarcada = checkBoxFecha.Checked;
            DateTime fini = dtPickerDesde.Value.Date.AddHours(0).AddMinutes(0).AddSeconds(0);
            DateTime ffin = dtPickerHasta.Value.Date.AddHours(23).AddMinutes(59).AddSeconds(59);

            if (cmbBTipoComprobante.SelectedItem == null)
                cmbBTipoComprobante.SelectedIndex = 0;

            int asignado = 3;                           //todos
            if (rBtnAsignados.Checked) asignado = 1;    //asignados
            if (rBtnNoAsignados.Checked) asignado = 2;  //no asignados

            string uuid = text.Text;
            if (cboxUUID.Checked)
            {
                Tuple<string, string> codQRyUuid = ObtieneContenidoQRCorrecto(text.Text);
                text.Text = codQRyUuid.Item1;
                uuid = codQRyUuid.Item2;
            }

            listaDeCfdisFiltrados = mainController.getFacturas( asignado,
                                        cboxUUID.Checked, uuid, string.Empty,
                                        cbFechaMarcada, fini, ffin,
                                        checkBoxTipoComprobante.Checked, cmbBTipoComprobante.SelectedItem.ToString(),
                                        cBoxRfcEmisor.Checked, tboxRFCEmisor.Text,
                                        ExisteLista, ComprobantesABuscar,
                                        false, string.Empty, string.Empty);

            //gridFiles.Columns.Clear();

            //DataGridViewColumn col = new DataGridViewTextBoxColumn();
            //col.DataPropertyName = "archivo";
            //col.HeaderText = "Archivo";
            //col.Name = "col1";
            //gridFiles.Columns.Add(col);

            //col = new DataGridViewTextBoxColumn();
            //col.DataPropertyName = "selloValido";
            //col.HeaderText = "Sello";
            //col.Name = "selloValido";
            //gridFiles.Columns.Add(col);

            bindingSource3.DataSource = listaDeCfdisFiltrados;
            gridFiles.AutoGenerateColumns = false;
            gridFiles.DataSource = bindingSource3;
            gridFiles.AutoResizeColumns();
            gridFiles.Refresh();

            InicializaCheckBoxDelGrid(gridFiles, idxChkBox, true);

            return listaDeCfdisFiltrados.Count;
        }

        private Tuple<string, string> ObtieneContenidoQRCorrecto(string text)
        {
            string cadenaQR = text;
            string uuid = text;
            if (cadenaQR.Contains("https") && cadenaQR.Contains("id=") && cadenaQR.Contains("&re="))
            {
                uuid = ObtieneUuidDeCadenaQR(cadenaQR);
            }

            if (cadenaQR.Contains("https") && cadenaQR.Contains("id¿") && cadenaQR.Contains("re¿"))
            {
                cadenaQR = cadenaQR.Replace('¿', '=').Replace('/', '&').Replace('_', '?').Replace('\'', '-');
                cadenaQR = cadenaQR.Remove(0, 8);
                cadenaQR = string.Concat("https://", cadenaQR);

                uuid = ObtieneUuidDeCadenaQR(cadenaQR);
            }

            return new Tuple<string, string>(cadenaQR, uuid);
        }

        private static string ObtieneUuidDeCadenaQR(string cadenaQR)
        {
            int ini = cadenaQR.IndexOf("id=") + 3;
            int fin = cadenaQR.IndexOf("re=");
            int len = fin - ini -1;
            if (len > 20 && ini > 0)
                return cadenaQR.Substring(ini, len);
            else
                return cadenaQR;
        }


        /// <summary>
        /// Filtra las facturas marcadas en el grid.
        /// </summary>
        /// <param name=""></param>
        /// <returns>bool: True indica que la lista ha sido filtrada exitosamente</returns>
        public IList<vwComprobanteCFDI> filtraListaSeleccionada(DataGridView dg, ToolStripProgressBar tsp, short idxCheckBox, short idxTipo, short idxUuid, IList<vwComprobanteCFDI> lFacturas)
        {
            int i = 1;
            dg.EndEdit();
            tsp.Value = 0;
            IList<vwComprobanteCFDI> lf = lFacturas;
            //cargar lista de no seleccionados
            foreach (DataGridViewRow dgvr in dg.Rows)
            {
                bool marca = (dgvr.Cells[idxChkBox].Value != null && (dgvr.Cells[idxChkBox].Value.Equals(true) || dgvr.Cells[idxChkBox].Value.ToString().Equals("1")));
                lf.Where(x => x.TIPOCOMPROBANTE.Equals(dgvr.Cells[idxTipo].Value.ToString()) && x.UUID.Equals(dgvr.Cells[idxUuid].Value.ToString()))
                         .First().marcado = marca;

                tsp.Value = Convert.ToInt32(i * 100 / dg.RowCount);
                i++;
            }

            tsp.Value = 0;
            bool vacio = dg.RowCount == lf.Where(x => x.marcado.Equals(false)).ToList().Count;
            if (vacio)
                throw new ArgumentNullException("[filtraListaSeleccionada] No ha marcado ningún documento. Marque al menos una casilla en la primera columna para continuar con el proceso.\r\n");

            var marcadas = lf.Where(x => x.marcado.Equals(true)).ToList();
            return (marcadas);

        }

        private void tsButtonImportarArchivos_Click(object sender, EventArgs e)
        {
            lblError.Text = "";
            lblProcesos.Text = "";

            GPCompras gpCompras = new GPCompras(companySelected());

            IList<vwComprobanteCFDI> archivos = filtraListaSeleccionada(gridFiles, tsProgressBar, idxChkBox, idxTipo, idxUuid, listaDeCfdisFiltrados);

            gpCompras.ErrorImportarPM += new EventHandler<GPCompras.ErrorImportarPMEventArgs>(oL_ErrorImportarPM);
            gpCompras.ProcesoOkImportarPM += new EventHandler<GPCompras.ProcesoOkImportarPMEventArgs>(oL_ProcesoOkImportarPM);

            int metodo = 1;
            if (radPOP.Checked)
                metodo = 2;

            int lenUsuario = Environment.UserName.PadLeft(5).Length;
            string usuario = Environment.UserName.Substring(0, 1) + Environment.UserName.PadLeft(5).Substring(lenUsuario - 4, 4);
            gpCompras.IntegrarDocumentosGP(archivos, metodo, usuario);

            if (archivos.Count == 0)
                MessageBox.Show("Debe seleccionar archivos");

            gridFiles.Refresh();

        }

        private List<string> ObtieneListaDeCfdis()
        {
            List<string> archivos = new List<string>();

            foreach (DataGridViewRow row in gridFiles.Rows)
            {
                var item = row.DataBoundItem;
                if (item != null)
                {
                    System.Type type = item.GetType();
                    string archivo = (string)type.GetProperty("archivo").GetValue(item, null);
                    string directorio = (string)type.GetProperty("directorio").GetValue(item, null);

                    archivos.Add(directorio + "\\" + archivo);
                }
            }

            return archivos;
        }


        #endregion

        private void toolStripButton1_Click(object sender, EventArgs e)
        {
            if (gridVista.SelectedRows.Count != 0)
            {
                try
                {
                    string carpeta = System.Configuration.ConfigurationManager.AppSettings[companySelected() + "_directorio"].ToString();
                    DcemVwContabilidad item = (DcemVwContabilidad)gridVista.SelectedRows[0].DataBoundItem;
                    if (item != null)
                    {
                        var iTipoDoc = lParametros.Where(x => x.Tipo == item.tipodoc);
                        string nombreArchivo = iTipoDoc.First().Archivo;
                        nombreArchivo = Path.GetFileNameWithoutExtension(nombreArchivo) + "_" + DateTime.Now.ToString("yyyyMMdd HHmmss");
                        string archivo = Path.Combine(carpeta, nombreArchivo + ".xlsx");

                        object items = mostrarContenido(item.year1, item.periodid, item.tipodoc);
                        DataTable dtItems = ContabilidadElectronicaPresentacion.ConvierteLinqQueryADataTable((IEnumerable<dynamic>)items);
                        var wb = new ClosedXML.Excel.XLWorkbook();

                        dtItems.TableName = "test";
                        wb.Worksheets.Add(dtItems);
                        //wb.Worksheet(1).Cell("B1").Value = "0";
                        
                        //wb.Worksheet(1).Column(2).CellsUsed().SetDataType(XLDataType.Number);

                        //wb.Worksheet(1).Cell("B1").Value = "Saldo Inicial";

                        wb.SaveAs(archivo);
                        UtilitarioArchivos.AbrirArchivo(archivo);
                        lblProcesos.Text = "Archivo guardado en: " + archivo;

                    }
                }
                catch(Exception exl)
                {

                    grid.DataSource = null;
                    lblError.Text = exl.Message;

                }
            }

        }

        private void gridVista_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0) gridVista.EndEdit();

        }

        private void btnBuscar_Click(object sender, EventArgs e)
        {
            try
            {
                lblProcesos.Text = "";
                var errores = validarFiltrosPreFacturas();
                if (errores == "")
                {
                    var c = FiltrarComprobantes(false, null);
                    lblProcesos.Text = "";
                    lblProcesos.AppendText("Total de documentos encontrados: " + c + Environment.NewLine);
                }
                else
                    lblProcesos.Text = errores;

                ReiniciarLaSeccionDelContenidoXml();
                if (gridFiles.RowCount != 0)
                {
                    gridFiles.Rows[0].Selected = true;
                    MuestraContenidoCfdiXml();
                }
            }
            catch (Exception exc)
            {
                lblProcesos.Text = string.Concat(exc.Message, Environment.NewLine, exc?.InnerException.ToString(), Environment.NewLine);
            }

        }

        private string validarFiltrosPreFacturas()
        {
            string errores = "";
            if (checkBoxFecha.Checked)
            {
                if (dtPickerDesde.Value > dtPickerHasta.Value)
                    errores += "El campo fecha inicial debe ser menor que la fecha final." + Environment.NewLine;
            }

            return errores;
        }

        private void checkBoxFecha_CheckedChanged(object sender, EventArgs e)
        {
            dtPickerDesde.Value = DateTime.Today.AddDays(-365);
        }

        private void cBoxMark_CheckedChanged(object sender, EventArgs e)
        {
            InicializaCheckBoxDelGrid(gridFiles, idxChkBox, cBoxMark.Checked);

        }

        private void tboxUuid_TextChanged(object sender, EventArgs e)
        {
            cboxUUID.Checked = true;
        }

        private void cmbEmpresas_SelectedIndexChanged_1(object sender, EventArgs e)
        {
            ReiniciarLaSeccionDelContenidoXml();
            gridFiles.DataSource = null;

            string defaultpmpop = System.Configuration.ConfigurationManager.AppSettings[companySelected() + "_defaultPMoPOP"].ToString();
            if (defaultpmpop.Equals("PM"))
                radPM.Checked = true;

            if (defaultpmpop.Equals("POP"))
                radPOP.Checked = true;
        }

        private void ReiniciarLaSeccionDelContenidoXml()
        {
            dataGridView1.DataSource = null;
            dataGridView2.DataSource = null;
            dataGridView3.DataSource = null;
            dataGridView4.DataSource = null;
            dataGridView5.DataSource = null;
            dataGridView6.DataSource = null;
            dataGridView7.DataSource = null;
        }
    }
}
