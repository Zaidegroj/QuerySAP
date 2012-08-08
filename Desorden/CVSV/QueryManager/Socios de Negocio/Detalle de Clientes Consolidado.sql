select [Grupo],[Grupo de Cliente],[Cliente],[Nombre del Cliente],[Condicion de Pago],[Saldo de Cuenta],[Direccion],[Telefono],[NIT],[Registro],[Giro],paisdesc as Pais 
		from 
			(
				SELECT	T0.GroupCode as [Grupo],T1.GroupName as [Grupo de Cliente],T0.CardCode as [Cliente],T0.CardName as [Nombre del Cliente],
						t2.PymntGroup as [Condicion de Pago],T0.Balance as [Saldo de Cuenta],
						t0.address as Direccion,t0.phone1 as Telefono,t0.u_nit as NIT,t0.u_nrc as Registro,t0.u_giro as Giro,0 as PaisId,'Guatemala' as PaisDesc
				FROM	cvgt.dbo.OCRD T0 INNER JOIN cvgt.dbo.OCRG T1 ON T0.GroupCode = T1.GroupCode
						inner join cvgt.dbo.octg T2 on t2.groupnum = t0.groupnum
				 WHERE T0.CardType ='C'

				union all 

				SELECT	T0.GroupCode as [Grupo],T1.GroupName as [Grupo de Cliente],T0.CardCode as [Cliente],T0.CardName as [Nombre del Cliente],
						t2.PymntGroup as [Condicion de Pago],T0.Balance as [Saldo de Cuenta],
						t0.address as Direccion,t0.phone1 as Telefono,t0.u_nit as NIT,t0.u_nrc as Registro,t0.u_giro as Giro,1 as PaisId,'El Salvador' as PaisDesc
				FROM	cvsv.dbo.OCRD T0 INNER JOIN cvsv.dbo.OCRG T1 ON T0.GroupCode = T1.GroupCode
						inner join cvsv.dbo.octg T2 on t2.groupnum = t0.groupnum
				 WHERE T0.CardType ='C'

				union all 

				SELECT	T0.GroupCode as [Grupo],T1.GroupName as [Grupo de Cliente],T0.CardCode as [Cliente],T0.CardName as [Nombre del Cliente],
						t2.PymntGroup as [Condicion de Pago],T0.Balance as [Saldo de Cuenta],
						t0.address as Direccion,t0.phone1 as Telefono,t0.u_nit as NIT,t0.u_nrc as Registro,t0.u_giro as Giro,2 as PaisId,'Honduras' as PaisDesc
				FROM	cvhn.dbo.OCRD T0 INNER JOIN cvhn.dbo.OCRG T1 ON T0.GroupCode = T1.GroupCode
						inner join cvhn.dbo.octg T2 on t2.groupnum = t0.groupnum
				 WHERE T0.CardType ='C'
					
				union all 

				SELECT	T0.GroupCode as [Grupo],T1.GroupName as [Grupo de Cliente],T0.CardCode as [Cliente],T0.CardName as [Nombre del Cliente],
						t2.PymntGroup as [Condicion de Pago],T0.Balance as [Saldo de Cuenta],
						t0.address as Direccion,t0.phone1 as Telefono,t0.u_nit as NIT,t0.u_nrc as Registro,t0.u_giro as Giro,3 as PaisId,'Nicaragua' as PaisDesc
				FROM	cvni.dbo.OCRD T0 INNER JOIN cvni.dbo.OCRG T1 ON T0.GroupCode = T1.GroupCode
						inner join cvni.dbo.octg T2 on t2.groupnum = t0.groupnum
				 WHERE T0.CardType ='C'

				union all

				SELECT	T0.GroupCode as [Grupo],T1.GroupName as [Grupo de Cliente],T0.CardCode as [Cliente],T0.CardName as [Nombre del Cliente],
						t2.PymntGroup as [Condicion de Pago],T0.Balance as [Saldo de Cuenta],
						t0.address as Direccion,t0.phone1 as Telefono,t0.u_nit as NIT,t0.u_nrc as Registro,t0.u_giro as Giro,4 as PaisId,'Costa Rica' as PaisDesc
				FROM	cvcr.dbo.OCRD T0 INNER JOIN cvcr.dbo.OCRG T1 ON T0.GroupCode = T1.GroupCode
						inner join cvcr.dbo.octg T2 on t2.groupnum = t0.groupnum
				 WHERE T0.CardType ='C'

				union all 

				SELECT	T0.GroupCode as [Grupo],T1.GroupName as [Grupo de Cliente],T0.CardCode as [Cliente],T0.CardName as [Nombre del Cliente],
						t2.PymntGroup as [Condicion de Pago],T0.Balance as [Saldo de Cuenta],
						t0.address as Direccion,t0.phone1 as Telefono,t0.u_nit as NIT,t0.u_nrc as Registro,t0.u_giro as Giro,5 as PaisId,'Panama' as PaisDesc
				FROM	cvpa.dbo.OCRD T0 INNER JOIN vmpa.dbo.OCRG T1 ON T0.GroupCode = T1.GroupCode
						inner join vmpa.dbo.octg T2 on t2.groupnum = t0.groupnum
				 WHERE T0.CardType ='C'

				) Dt0

order by Dt0.PaisId