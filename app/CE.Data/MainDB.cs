//using Comun;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CE.Data
{
    public class MainDB
    {
        public string connectionString { get; set; }

        // Rango de fechas para generar prefacturas
        public DateTime fechaDesdePref { get; set; }
        public DateTime fechaHastaPref { get; set; }

        public MainDB(string connectionString)
        {
            this.connectionString = connectionString;
        }

        #region Eventos
        public event EventHandler<ErrorEventArgsEntidadesGP> eventoErrDB;

        protected virtual void OnErrorDB(ErrorEventArgsEntidadesGP e)
        {
            //si no es null notificar
            eventoErrDB?.Invoke(this, e);
        }

        #endregion

        public void setConnectionString(string connection)
        {
            this.connectionString = connection;
        }

        //// Permite comprobar la conexión con la base de datos
        public bool probarConexion()
        {
            using (var db = this.getDbContext())
            {
                return db.Database.Exists();
            }
        }

        public MexGPEntities getDbContext()
        {
            if (string.IsNullOrEmpty(this.connectionString))
                return new MexGPEntities();

            return new MexGPEntities(this.connectionString);
        }

        //// Devuelve las prefacturas que cumplan con los criterios de filtrado seleccionados
        public IList<vwComprobanteCFDI> getFacturas(int asignados,
                                                    bool filtrarUUid, string uuid, string numPFHasta,
                                                    bool filtrarFecha, DateTime fechaDesde, DateTime fechaHasta,
                                                    bool filtrarTipo, string tipoComprobante,
                                                    bool filtrarEmisor, string idEmisor,
                                                    bool filtrarListaComprobantes, List<string> comprobantesABuscar,
                                                    bool filtrarSopnumber, string sopnumberDesde, string sopnumberHasta)
        {
            string fdesde = fechaDesde.ToString("yyyy-MM-dd");
            string fhasta = fechaHasta.ToString("yyyy-MM-dd");
            using (var db = this.getDbContext())
            {
                // verificar la conexión con el servidor de bd
                if (!this.probarConexion())
                {
                    ErrorEventArgsEntidadesGP args = new ErrorEventArgsEntidadesGP();
                    args.mensajeError = "No se pudo establecer la conexión con el servidor al tratar de leer los cfdis.";
                    OnErrorDB(args);
                }

                var datos = db.vwComprobanteCFDI.AsQueryable();

                if (asignados == 1)        //01 asignados
                {
                    datos = datos.Where(m => !m.VCHRNMBR.Equals(string.Empty));
                }
                else if (asignados == 2)   //10 No asignados
                {
                    datos = datos.Where(m => m.VCHRNMBR.Equals(string.Empty));
                }
                
                // Filtrado por uuid
                if (filtrarUUid)
                {
                    if (uuid != "")
                    {
                        datos = datos.Where(m => m.UUID.Contains(uuid));
                    }
                }

                // Filtrado por fecha string
                if (filtrarFecha)
                {
                    datos = datos.Where(m => m.FECHA.Substring(0, 10).CompareTo(fdesde) >= 0 && m.FECHA.Substring(0, 10).CompareTo(fhasta) <= 0);
                }

                if (filtrarTipo && !string.IsNullOrEmpty(tipoComprobante))
                {
                    datos = datos.Where(m => m.TIPOCOMPROBANTE.Equals(tipoComprobante));
                }

                // Filtrado por id de emisor
                if (filtrarEmisor && idEmisor != "")
                {
                    datos = datos.Where(m => m.EMISOR_RFC.Contains(idEmisor));
                }

                // Filtrado por lista
                if (filtrarListaComprobantes && comprobantesABuscar != null)
                {
                    var d = datos.Select(i => i.UUID).Intersect(comprobantesABuscar);
                    datos = datos.Where(m => d.Contains(m.UUID));
                    //datos = datos.Where(m => comprobantesABuscar.Contains(m.UUID));
                }

                //// Filtrado por sopnumbe
                //if (filtrarSopnumber && sopnumberDesde != "")
                //{
                //    datos = datos.Where(m => m.sopnumbe.CompareTo(sopnumberDesde) >= 0);
                //}

                //// Filtrado por sopnumbe
                //if (filtrarSopnumber && sopnumberHasta != "")
                //{
                //    datos = datos.Where(m => m.sopnumbe.CompareTo(sopnumberHasta) <= 0);
                //}

                return datos?.ToList();
            }
        }




    }
}
