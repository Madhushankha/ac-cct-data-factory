# runs/<env>/_seeded-history

Only the latest run per set and environment was copied from the original ac-cct-data-seed.
`_seeded-history/manifest.json` lists every case that had a booking in the full history
(id, pnrId, locator, and the run it came from), so `seed --skip-seeded` still knows about
bookings from runs that were not copied. It is read the same way as any batch manifest.
